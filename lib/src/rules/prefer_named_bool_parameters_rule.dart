// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferNamedBoolParametersRule extends BaseLintRule<PreferNamedBoolParameters> {
  PreferNamedBoolParametersRule._(super.rule);

  factory PreferNamedBoolParametersRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'prefer_named_bool_parameters',
      paramsParser: PreferNamedBoolParameters.fromJson,
      problemMessage: (value) =>
          'Converting positional boolean parameters to named parameters helps you avoid situations with a wrong value passed to the parameter.',
    );

    return PreferNamedBoolParametersRule._(rule);
  }

  void _verify(
    FormalParameterList parameters,
    ErrorReporter reporter,
  ) {
    if (parameters.parameters.isEmpty) return;
    if ((config.parameters.ignoreSingle) && (parameters.length == 1)) return;
    if ((config.parameters.ignoreSingleBoolean) && _onlyOne(parameters.parameters)) return;

    for (final p in parameters.parameters.whereType<SimpleFormalParameter>()) {
      if ((p.type!.type?.isDartCoreBool ?? false) && !p.isNamed) {
        reporter.reportErrorForNode(code, p, [p.name?.lexeme ?? ''], [], parameters);
      }
    }
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((MethodDeclaration node) {
      if (node.parameters == null) return;
      _verify(node.parameters!, reporter);
    });

    context.registry.addFunctionDeclaration((FunctionDeclaration node) {
      if (node.functionExpression.parameters == null) return;
      _verify(node.functionExpression.parameters!, reporter);
    });
  }

  bool _onlyOne(NodeList<FormalParameter> parameters) =>
      parameters.where((e) => !e.isNamed).where((e) => e.isBool).length == 1;

  @override
  List<Fix> getFixes() => <Fix>[_PreferNamedBoolParametersFix()];
}

class _PreferNamedBoolParametersFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodDeclaration((node) {
      final parameters = analysisError.data! as FormalParameterList;

      update(reporter, parameters);
    });

    context.registry.addFunctionDeclaration((node) {
      final parameters = analysisError.data! as FormalParameterList;

      update(reporter, parameters);
    });
  }

  void update(ChangeReporter reporter, FormalParameterList parameters) {
    final changeBuilder = reporter.createChangeBuilder(
      message: 'Convert to named parameters',
      priority: 80,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addReplacement(
        range.startEnd(parameters.beginToken.next!, parameters.endToken.previous!),
        (builder) {
          for (final p in parameters.parameters
              .where((e) => !e.isNamed)
              .where((e) => !e.isBool)
              .whereType<SimpleFormalParameter>()) {
            builder.write('${p.type} ${p.name?.lexeme}, ');
          }
          builder.write('{');
          for (final p in parameters.parameters
              .where((e) => e.isNamed)
              .where((e) => !e.isBool)
              .whereType<SimpleFormalParameter>()) {
            builder.write('required ${p.type} ${p.name?.lexeme}, ');
          }
          for (final p in parameters.parameters
              .where((e) => !e.isNamed)
              .where((e) => e.isBool)
              .whereType<SimpleFormalParameter>()) {
            builder.write('required ${p.type} ${p.name?.lexeme}, ');
          }
          builder.write('}');
        },
      );
      builder.format(range.node(parameters));
    });
  }
}

class PreferNamedBoolParameters {
  final bool ignoreSingle;
  final bool ignoreSingleBoolean;

  factory PreferNamedBoolParameters.fromJson(Map<String, Object?> map) {
    final ignoreSingle = map['ignore-single'] as bool? ?? false;
    final ignoreSingleBoolean = map['ignore-single-boolean'] as bool? ?? false;

    return PreferNamedBoolParameters(ignoreSingle: ignoreSingle, ignoreSingleBoolean: ignoreSingleBoolean);
  }

  PreferNamedBoolParameters({required this.ignoreSingle, required this.ignoreSingleBoolean});
}
