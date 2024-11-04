import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/utils.dart';
import 'package:yaml/yaml.dart';

class UnusedParameterRule extends BaseLintRule<UnusedParameters> {
  UnusedParameterRule._(super.rule);

  factory UnusedParameterRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'unused_parameter',
      paramsParser: UnusedParameters.fromJson,
      problemMessage: (value) => 'This parameter is not used.',
    );

    return UnusedParameterRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      if (node.metadata.any((e) => e.name.name.startsWith('Deprecated'))) return;
      final parameters = node.functionExpression.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return;

      final simpleIdentifiers = <SimpleIdentifier>[];
      final visitor = RecursiveSimpleIdentifierVisitor(
        onVisitSimpleIdentifier: simpleIdentifiers.add,
      );
      node.functionExpression.body.accept(visitor);

      final items = parameters
          .where((e) => !config.parameters.values.contains(e.name?.lexeme ?? ''))
          .where((e) => e.declaredElement != null)
          .where((e) => !simpleIdentifiers.map((i) => i.staticElement).contains(e.declaredElement));

      for (final p in items) {
        reporter.reportErrorForNode(code, p, [p.name?.lexeme ?? ''], [], (p, parameters));
      }
    });

    context.registry.addMethodDeclaration((node) {
      if (node.metadata.any((e) => e.name.name.startsWith('Deprecated'))) return;
      final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
      if (classDeclaration == null) return;

      final isAbstractClass = classDeclaration.abstractKeyword != null;
      if (isAbstractClass) return;

      final isOverrideMethod = node.metadata.any((e) => e.name.name == 'override');
      if (isOverrideMethod) return;

      final parameters = node.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return;

      final simpleIdentifiers = <SimpleIdentifier>[];
      final visitor = RecursiveSimpleIdentifierVisitor(
        onVisitSimpleIdentifier: simpleIdentifiers.add,
      );
      node.body.accept(visitor);

      final items = parameters
          .where((e) => !config.parameters.values.contains(e.name?.lexeme ?? ''))
          .where((e) => e.declaredElement != null)
          .where((e) => !simpleIdentifiers.map((i) => i.staticElement).contains(e.declaredElement));

      for (final p in items) {
        reporter.reportErrorForNode(code, p, [p.name?.lexeme ?? ''], [], (p, parameters));
      }
    });
  }

  @override
  List<Fix> getFixes() => [UnusedParameterFix()];
}

class UnusedParameterFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;
      update(analysisError, reporter);
    });

    context.registry.addFunctionDeclaration((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;
      update(analysisError, reporter);
    });
  }

  void update(AnalysisError analysisError, ChangeReporter reporter) {
    final (p, parameters) = analysisError.data! as (FormalParameter, NodeList<FormalParameter>);

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Remove ${p.name?.lexeme ?? 'undefined'} parameter',
      priority: 80,
    );

    // ignore: cascade_invocations
    changeBuilder.addDartFileEdit((builder) {
      final isLast = p == parameters.last;
      final rangeToDelete = switch ((isLast, parameters.length > 1)) {
        (true, true) => range.startEnd(parameters[parameters.length - 2].endToken.next!, p.endToken),
        (true, false) => range.node(p),
        _ => range.startEnd(p, p.endToken.next!),
      };
      builder
        ..addDeletion(rangeToDelete)
        ..format(range.startEnd(parameters[0].beginToken, parameters.last.endToken));
    });
  }
}

class UnusedParameters {
  final List<String> values;

  factory UnusedParameters.fromJson(Map<String, Object?> map) {
    return UnusedParameters(
      values: List<String>.from(map['parameters'] as YamlList),
    );
  }

  UnusedParameters({required this.values});

  @override
  String toString() => values.join(', ');
}
