// ignore_for_file: unused_import

library my_custom_lints;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/assists/check_state_getter_assist.dart';
import 'package:my_custom_lints/src/assists/copy_with_nullable_assist.dart';
import 'package:my_custom_lints/src/assists/may_be_map_method_assist.dart';
import 'package:my_custom_lints/src/assists/may_be_when_method_assist.dart';
import 'package:my_custom_lints/src/common/annotations.dart';
import 'package:my_custom_lints/src/bloc/add_cubit_suffix_rule.dart';
import 'package:my_custom_lints/src/rules/always_call_super_props_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_assignments_as_conditions_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_bang_operator_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_banned_type_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_banned_usage_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_cached_network_image_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_dynamic_rule.dart';
import 'package:my_custom_lints/src/bloc/avoid_empty_build_when_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_empty_set_state_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_equal_expression_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_extension_on_enum_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_getter_prefix_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_ignoring_return_values_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_incomplete_copy_with_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_invalid_prefix_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_inverted_boolean_checks_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_local_function_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_long_parameter_list_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_long_records_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_map_keys_contains_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_mixing_named_and_positional_fields_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_multi_assignment_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_mutating_parameters_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_nested_conditional_expressions_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_nested_if.dart';
import 'package:my_custom_lints/src/rules/avoid_nested_record_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_nested_switch_expressions_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_nullable_boolean_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_nullable_list_return_type_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_only_rethrow_rule.dart';
import 'package:my_custom_lints/src/bloc/avoid_passing_bloc_to_bloc_rule.dart';
import 'package:my_custom_lints/src/bloc/avoid_passing_build_context_to_blocs_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_plus_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_positional_record_field_access_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_print_rule.dart';
import 'package:my_custom_lints/src/bloc/avoid_read_inside_build_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_return_padding_in_build_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_self_assignment_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_shadowed_extension_methods_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_shrink_wrap_in_lists_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_single_child_column_or_row_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_throw_in_catch_block_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_throw_litteral_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_unnecessary_setstate_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_unused_parameters.dart';
import 'package:my_custom_lints/src/rules/avoid_useless_spread_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_using_buildcontext_after_await_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_watch_outside_build_rule.dart';
import 'package:my_custom_lints/src/bloc/avoid_widget_function_rule.dart';
import 'package:my_custom_lints/src/rules/binary_expression_operand_order_rule.dart';
import 'package:my_custom_lints/src/rules/boolean_prefix_rule.dart';
import 'package:my_custom_lints/src/rules/check_is_not_closed_after_async_gap_rule.dart';
import 'package:my_custom_lints/src/rules/cyclomatic_complexity_rule.dart';
import 'package:my_custom_lints/src/rules/do_not_use_datetime_now_rule.dart';
import 'package:my_custom_lints/src/rules/enum_constants_ordering_rule.dart';
import 'package:my_custom_lints/src/rules/first_init_state_rule.dart';
import 'package:my_custom_lints/src/rules/missing_field_in_equatable_props.dart';
import 'package:my_custom_lints/src/rules/no_boolean_literal_compare_rule.dart';
import 'package:my_custom_lints/src/rules/no_equal_then_else_rule.dart';
import 'package:my_custom_lints/src/rules/not_length_in_index_expression_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_any_or_every_rule.dart';
import 'package:my_custom_lints/src/bloc/prefer_bloc_extensions_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_contains_method_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_enum_with_sentinel_value_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_iterable_first_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_iterable_isempty_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_iterable_last_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_iterable_of_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_multi_bloc_provider_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_named_bool_parameters_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_named_parameters_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_no_growable_list_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_null_aware_notation_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_null_aware_spread_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_of_over_current.dart';
import 'package:my_custom_lints/src/rules/prefer_returning_condition_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_safe_firstwhere_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_throw_exception_or_error_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_underscore_for_unused_callback_parameters_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_usage_of_value_getter_rule.dart';
import 'package:my_custom_lints/src/rules/prefer_void_callback_rule.dart';
import 'package:my_custom_lints/src/bloc/remove_empty_listener_rule.dart';
import 'package:my_custom_lints/src/rules/use_join_string_list_rule.dart';
import 'package:my_custom_lints/src/rules/use_ternary_instead_of_ifelse_rule.dart';

PluginBase createPlugin() => _MyCustomLint();
const DataClass dataClass = DataClass();

class _MyCustomLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return <LintRule>[
      AvoidLongParameterListRule.createRule(configs),
      const AvoidDynamicRule(),
      const AvoidBangOperatorRule(),
      const AvoidWidgetFunctionRule(),
      const PreferReturningConditionRule(),
      const NoEqualThenElseRule(),
      const PreferIterableFirst(),
      const PreferIterableLast(),
      const NoBooleanLiteralCompareRule(),
      const NoLengthInIndexExpressionRule(),
      UnusedParameterRule.createRule(configs),
      const MissingFieldInEquatablePropsRule(),
      const AlwaysCallSuperPropsRule(),
      const AddCubitSuffixRule(),
      const FirstInitStateRule(),
      const PreferOfOverCurrentRule(),
      const PreferNoGrowableListRule(),
      const PreferUnderscoreForUnusedCallbackParameters(),
      const RemoveEmptyListenerRule(),
      const AvoidIncompleteCopyWithRule(),
      const AvoidNullableListReturnTypeRule(),
      const AvoidLocalFunctionRule(),
      PreferVoidCallbackRule.createRule(configs),
      BooleanPrefixesRule.createRule(configs),
      PreferIterableIsEmptyRule.createRule(configs),
      CyclomaticComplexityRule.createRule(configs),
      AvoidNestedIfRule.createRule(configs),
      const AvoidPlusRule(),
      const AvoidUselessSpreadRule(),
      const AvoidInvertedBooleanChecksRule(),
      const AvoidMapKeysContainsRule(),
      const UseTernaryInsteadOfIfElse(),
      const AvoidExtensionOnEnumRule(),
      AvoidNullableBooleanRule.createRule(configs),
      const AvoidEqualExpressionsRule(),
      const AvoidSelfAssignmentRule(),
      const AvoidGetterPrefixRule(),
      const PreferEnumWithSentinelValueRule(),
      AvoidSingleChildColumnOrRowRule.createRule(configs),
      const AvoidPositionalRecordFieldAccessRule(),
      const AvoidAssignmentsAsConditionsRule(),
      const AvoidShrinkWrapInListRule(),
      const AvoidOnlyRethrowRule(),
      const AvoidInvalidPrefixRule(),
      const EnumConstantsOrderingRule(),
      const AvoidEmptySetStateRule(),
      const AvoidUnnecessarySetStateRule(),
      const AvoidMultiAssignmentRule(),
      const AvoidNestedRecordRule(),
      const AvoidMixingNamedAndPositionalFieldsRule(),
      const PreferContainsMethodRule(),
      const PreferSafeFirstWhereRule(),
      const UseJoinOnStringsRule(),
      const PreferMultiBlocProviderRule(),
      const AvoidReadInsideBuildRule(),
      const AvoidWatchOutsideBuildRule(),
      const AvoidIgnoringReturnValuesRule(),
      const BinaryExpressionOperandOrderRule(),
      const AvoidEmptyBuildWhenRule(),
      const AvoidMutatingParametersRule(),
      const DoNotUseDatetimeNowRule(),
      AvoidNestedConditionalExpressionsRule.createRule(configs),
      const AvoidNestedSwitchExpressionRule(),
      const CheckIsNotClosedAfterAsyncGapRule(),
      const PreferNullAwareNotationRule(),
      const PreferThrowExceptionOrErrorRule(),
      const AvoidThrowInCatchBlockRule(),
      const PreferBlocExtensionsRule(),
      const AvoidPassingbuildContextToBlocsRule(),
      const AvoidPassingblocToBlocRule(),
      const AvoidReturnPaddingRule(),
      const AvoidUsingBuildContextAwaitRule(),
      const AvoidShadowedExtensionMethodsRule(),
      const PreferIterableOfRule(),
      const PreferNullAwareSpreadRule(),
      PreferNamedParametersRule.createRule(configs),
      AvoidLongRecordsRule.createRule(configs),
      PreferNamedBoolParametersRule.createRule(configs),
      PreferAnyOrEveryRule.createRule(configs),
      AvoidBannedTypeRule.createRule(configs),
      AvoidBannedUsageRule.createRule(configs)
    ];
  }

  @override
  List<Assist> getAssists() {
    return <Assist>[
      // CopyWithNullableAssist(),
      // MaybeWhenMethodAssist(),
      // MaybeMapMethodAssist(),
      // CheckStateGetterAssist(),
    ];
  }
}
