// ignore_for_file: pattern_never_matches_value_type

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class RemoveEmptyListenerRule extends DartLintRule {
  static const lintName = 'remove_empty_listener';
  static const listenerName = 'listener';

  const RemoveEmptyListenerRule()
    : super(
        code: const LintCode(
          name: lintName,
          problemMessage: 'Remove empty listener and replace BlocConsumer by a BlocBuilder.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme == 'BlocConsumer') {
        final hasNoListener = node.argumentList.arguments.whereType<NamedExpression>().every(
          (e) => e.name.label.name != listenerName,
        );
        if (hasNoListener) return;

        final listenerArgument =
            node.argumentList.arguments.firstWhere((e) => e is NamedExpression && e.name.label.name == listenerName)
                as NamedExpression;
        if (listenerArgument.expression is! FunctionExpression) return;

        final body = (listenerArgument.expression as FunctionExpression).body;
        if (body is BlockFunctionBody && body.block.statements.isEmpty) {
          reporter.reportErrorForNode(code, listenerArgument);
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [RemoveEmptyListenerFix()];
}

class RemoveEmptyListenerFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme == 'BlocConsumer') {
        final hasNoListener = node.argumentList.arguments.whereType<NamedExpression>().every(
          (e) => e.name.label.name != 'listener',
        );
        if (hasNoListener) return;

        final listenerArgument =
            node.argumentList.arguments.firstWhere((e) => e is NamedExpression && e.name.label.name == 'listener')
                as NamedExpression;

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Remove the listener and replace BlocConsumer by a BlocBuilder.',
          priority: 80,
        );

        // ignore: cascade_invocations
        changeBuilder.addDartFileEdit((builder) {
          // ignore: cascade_invocations
          builder.addSimpleReplacement(
            range.startLength(node.constructorName.type.name2, node.constructorName.type.name2.length),
            'BlocBuilder',
          );
          // ignore: cascade_invocations
          builder
            ..addDeletion(
              node.argumentList.arguments.last.endToken.next != null &&
                      node.argumentList.arguments.last.endToken.next!.type == TokenType.COMMA
                  ? range.startEnd(listenerArgument, node.argumentList.arguments.last.endToken.next!)
                  : range.node(listenerArgument),
            )
            ..format(range.node(node));
        });
      }
    });
  }
}
