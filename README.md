# my_custom_lints

A new Flutter package project.

## How to use the linter

To use `my_custom_lints` in your Dart or Flutter project, you need to enable it in your `analysis_options.yaml` file.

1.  **Add `my_custom_lints` to your `pubspec.yaml`:**

    If you are developing the linter locally, you can use a path dependency:

    ```yaml
    dev_dependencies:
      my_custom_lints:
        path: <path_to_my_custom_lints_package>
    ```

    If you are consuming it from pub.dev (once published), add it like a regular dependency:

    ```yaml
    dev_dependencies:
      my_custom_lints: ^0.0.1 # Replace with the actual version
    ```

2.  **Enable the linter in `analysis_options.yaml`:**

    Create or update your `analysis_options.yaml` file to include the following:

    ```yaml
    analyzer:
      plugins:
        - my_custom_lints
    ```

3.  **Run the analyzer:**

    The lints will now be reported by the Dart analyzer. You can run it manually with:

    ```bash
    dart analyze
    ```

    Or, if you are using an IDE like VS Code or Android Studio with the Dart/Flutter plugins, lints will be shown directly in the editor.

For more information on configuring custom lints, refer to the official `custom_lint` documentation: [https://pub.dev/packages/custom_lint](https://pub.dev/packages/custom_lint)

## List of available lints

The following lint rules are available:

*   `AvoidLongParameterListRule`
*   `AvoidDynamicRule`
*   `AvoidBangOperatorRule`
*   `AvoidWidgetFunctionRule`
*   `PreferReturningConditionRule`
*   `NoEqualThenElseRule`
*   `PreferIterableFirst`
*   `PreferIterableLast`
*   `NoBooleanLiteralCompareRule`
*   `NoLengthInIndexExpressionRule`
*   `UnusedParameterRule`
*   `MissingFieldInEquatablePropsRule`
*   `AlwaysCallSuperPropsRule`
*   `AddCubitSuffixRule`
*   `FirstInitStateRule`
*   `PreferOfOverCurrentRule`
*   `PreferNoGrowableListRule`
*   `PreferUnderscoreForUnusedCallbackParameters`
*   `RemoveEmptyListenerRule`
*   `AvoidIncompleteCopyWithRule`
*   `AvoidNullableListReturnTypeRule`
*   `AvoidLocalFunctionRule`
*   `PreferVoidCallbackRule`
*   `BooleanPrefixesRule`
*   `PreferIterableIsEmptyRule`
*   `CyclomaticComplexityRule`
*   `AvoidNestedIfRule`
*   `AvoidPlusRule`
*   `AvoidUselessSpreadRule`
*   `AvoidInvertedBooleanChecksRule`
*   `AvoidMapKeysContainsRule`
*   `UseTernaryInsteadOfIfElse`
*   `AvoidExtensionOnEnumRule`
*   `AvoidNullableBooleanRule`
*   `AvoidEqualExpressionsRule`
*   `AvoidSelfAssignmentRule`
*   `AvoidGetterPrefixRule`
*   `PreferEnumWithSentinelValueRule`
*   `AvoidSingleChildColumnOrRowRule`
*   `AvoidPositionalRecordFieldAccessRule`
*   `AvoidAssignmentsAsConditionsRule`
*   `AvoidShrinkWrapInListRule`
*   `AvoidOnlyRethrowRule`
*   `AvoidInvalidPrefixRule`
*   `EnumConstantsOrderingRule`
*   `AvoidEmptySetStateRule`
*   `AvoidUnnecessarySetStateRule`
*   `AvoidMultiAssignmentRule`
*   `AvoidNestedRecordRule`
*   `AvoidMixingNamedAndPositionalFieldsRule`
*   `PreferContainsMethodRule`
*   `PreferSafeFirstWhereRule`
*   `UseJoinOnStringsRule`
*   `PreferMultiBlocProviderRule`
*   `AvoidReadInsideBuildRule`
*   `AvoidWatchOutsideBuildRule`
*   `BinaryExpressionOperandOrderRule`
*   `AvoidEmptyBuildWhenRule`
*   `AvoidMutatingParametersRule`
*   `DoNotUseDatetimeNowRule`
*   `AvoidNestedConditionalExpressionsRule`
*   `AvoidNestedSwitchExpressionRule`
*   `CheckIsNotClosedAfterAsyncGapEmitRule`
*   `PreferNullAwareNotationRule`
*   `PreferThrowExceptionOrErrorRule`
*   `AvoidNumericLiteralsRule`
*   `AvoidThrowInCatchBlockRule`
*   `PreferBlocExtensionsRule`
*   `AvoidPassingbuildContextToBlocsRule`
*   `AvoidPassingblocToBlocRule`
*   `AvoidReturnPaddingRule`
*   `AvoidUsingBuildContextAwaitRule`
*   `AvoidShadowedExtensionMethodsRule`
*   `PreferIterableOfRule`
*   `PreferNullAwareSpreadRule`
*   `RemoveNullableAttributeRule`
*   `AvoidUselessAsyncMethodRule`
*   `AvoidContinueUsage`
*   `AvoidReturningValueFromCubitMethodsRule`
*   `AvoidUselessColumnRule`
*   `PreferImmediateReturnRule`
*   `AvoidUnconditionalBreakRule`
*   `AvoidUnnecessaryNullAssertionRule`
*   `PreferThrowingExceptionFirstRule`
*   `PreferNamedParametersRule`
*   `AvoidLongRecordsRule`
*   `PreferNamedBoolParametersRule`
*   `PreferAnyOrEveryRule`
*   `AvoidBannedTypeRule`
*   `AvoidBannedUsageRule`
*   `PreferCorrectCallbackFieldNBameRule`
*   `UseSetStateSynchronouslyRule`
*   `UnnecessaryToListRule`

## List of available assists

The following assists are available:

*   `EnumPredicateGettersAssist`
*   `EnumPatternMatchingAssist`
*   `CopyWithNullableAssist`
*   `MaybeWhenMethodAssist`
*   `MaybeMapMethodAssist`
*   `CheckStateGetterAssist`

## How to contribute

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the project's GitHub repository.

When contributing, please ensure:

1.  Your code adheres to the existing style.
2.  You add relevant tests for any new lints or assists.
3.  You update the documentation (this README) if necessary.
4.  Your commit messages are clear and descriptive.

We appreciate your help in making this linter better!
