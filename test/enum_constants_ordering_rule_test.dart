import 'package:my_custom_lints/src/rules/enum_constants_ordering_rule.dart';
import 'package:test/test.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;

// This is a stand-in. In a real scenario, custom_lint_builder might provide this.
// For now, we'll have to simulate or find the actual way to test.
// Due to the limitations of not being able to run code, I'll focus on the test case definitions.
// The actual execution would require the specific testing utilities from custom_lint_builder.

void main() {
  group('EnumConstantsOrderingRule', () {
    // Helper function (conceptual - would use actual testing utilities)
    Future<String?> _getFixedCode(String source) async {
      final rule = EnumConstantsOrderingRule();
      
      // 1. Parse the source code
      // In a real test environment, we'd use custom_lint_builder's resolver
      // For now, this is a simplified approach.
      final parseResult = parseString(
        content: source,
        featureSet: FeatureSet.latestLanguageVersion(),
        throwIfDiagnostics: false,
      );
      if (parseResult.errors.isNotEmpty && parseResult.errors.any((e) => e.errorCode.type == ErrorType.SYNTACTIC_ERROR)) {
        // If there's a syntax error, we can't reliably lint.
        // print('Syntax errors in source: ${parseResult.errors}');
        return source; // Or throw, depending on test expectations for malformed input
      }

      final errors = <AnalysisError>[];
      final errorReporter = RecordingErrorListener((error) => errors.add(error));
      final context = _MockCustomLintContext(); // Need a mock context
      final resolver = _MockCustomLintResolver(parseResult.unit.declaredElement!.library.source.uri, parseResult); // Mock resolver

      rule.run(resolver, errorReporter, context);

      if (errors.isEmpty) {
        return source; // No lint found, so no fix applied
      }

      // Assuming the first error is the one we want to fix
      final error = errors.first;
      final fixes = rule.getFixes();
      if (fixes.isEmpty) {
        return source; // No fix available
      }

      // Assuming the first fix is the one we want (_EnumConstantsOrderingFix)
      final fix = fixes.first as DartFix; 
      final changeBuilder = _MockChangeBuilder();
      
      // The actual run method of the fix needs a CustomLintResolver, ChangeReporter, CustomLintContext, AnalysisError, List<AnalysisError>
      // This part is tricky to mock perfectly without the actual testing framework.
      // The `analysisError.data` part is particularly important and hard to mock.
      // For the purpose of this exercise, I'll assume the fix can be applied conceptually.
      // In a real scenario, `custom_lint_builder` would provide utilities to handle this.

      // Let's try to simulate the data needed for the fix
      // The fix expects `analysisError.data` to be `NodeList<EnumConstantDeclaration>`
      // This is a simplification.
      final enumDeclaration = parseResult.unit.declarations
          .whereType<EnumDeclaration>()
          .firstWhere((e) => e.constants.isNotEmpty, orElse: () => throw Exception('No enum found with constants'));
      
      final mockAnalysisError = AnalysisError(
        parseResult.unit.declaredElement!.library.source,
        enumDeclaration.name.offset,
        enumDeclaration.name.length,
        rule.code,
        data: enumDeclaration.constants, // This is the crucial part
      );

      fix.run(resolver, changeBuilder, context, mockAnalysisError, errors);
      
      // Apply the changes from changeBuilder to the original source
      // This is also simplified. A real ChangeBuilder applies edits to a file.
      final sourceFile = plugin.SourceFile(parseResult.unit.declaredElement!.library.source.fullName, parseResult.content.length);
      final sourceEdit = changeBuilder.sourceFileEdit;

      if (sourceEdit == null) return source;

      String fixedCode = parseResult.content;
      // Apply edits in reverse order to maintain correct offsets
      final sortedEdits = List<plugin.SourceEdit>.from(sourceEdit.edits)
        ..sort((a, b) => b.offset.compareTo(a.offset));
      
      for (final edit in sortedEdits) {
        fixedCode = fixedCode.substring(0, edit.offset) +
                    edit.replacement +
                    fixedCode.substring(edit.offset + edit.length);
      }
      return fixedCode;
    }

    test('1. Enum with all constants having arguments', () async {
      const source = '''
enum MyEnum {
  zebra(1),
  alpha(2),
  beta(3, 'foo');
}
''';
      const expected = '''
enum MyEnum {
  alpha(2),
  beta(3, 'foo'),
  zebra(1);
}
''';
      // In a real test, we'd use a helper like:
      // expect(await testRule(EnumConstantsOrderingRule(), source), issues(...));
      // expect(await applyFix(EnumConstantsOrderingRule(), _EnumConstantsOrderingFix(), source), expected);
      // For now, using the conceptual _getFixedCode
      final fixedCode = await _getFixedCode(source);
      // The mock implementation is not perfect, so this assertion might not pass
      // without the real testing utilities. The key is the test case definition.
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), expected.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('2. Enum with no constants having arguments', () async {
      const source = '''
enum MyEnum {
  zebra,
  alpha,
  beta;
}
''';
      const expected = '''
enum MyEnum {
  alpha,
  beta,
  zebra;
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), expected.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('3. Enum with a mix of constants with and without arguments', () async {
      const source = '''
enum MyEnum {
  zebra(1),
  charlie,
  alpha,
  beta(2, 'foo');
}
''';
      const expected = '''
enum MyEnum {
  alpha,
  beta(2, 'foo'),
  charlie,
  zebra(1);
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), expected.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('4. Enum with "none" (no args) and others with arguments', () async {
      const source = '''
enum MyEnum {
  zebra(1),
  alpha(2),
  none,
  beta(3, 'foo');
}
''';
      const expected = '''
enum MyEnum {
  none,
  alpha(2),
  beta(3, 'foo'),
  zebra(1);
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), expected.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('5. Enum with "none" (with args) and others (mixed args)', () async {
      const source = '''
enum MyEnum {
  zebra(1),
  alpha,
  none('special'),
  beta(2, 'foo');
}
''';
      const expected = '''
enum MyEnum {
  none('special'),
  alpha,
  beta(2, 'foo'),
  zebra(1);
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), expected.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('6. Enum already in correct order (mixed arguments)', () async {
      const source = '''
enum MyEnum {
  none,
  alpha,
  beta(2, 'foo'),
  zebra(1);
}
''';
      // Since it's already sorted, no lint should be reported, and no changes made.
      // The _getFixedCode helper will return the original source if no lint is found.
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), source.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('7. Enum with only "none" and one other constant (with arguments)', () async {
      const source = '''
enum MyEnum {
  zebra(100),
  none;
}
''';
      const expected = '''
enum MyEnum {
  none,
  zebra(100);
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), expected.replaceAll(RegExp(r'\s+'), ' '));
    });
    
    test('Enum with only "none" (no args)', () async {
      const source = '''
enum MyEnum {
  none;
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), source.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('Enum with only "none" (with args)', () async {
      const source = '''
enum MyEnum {
  none('test');
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), source.replaceAll(RegExp(r'\s+'), ' '));
    });

    test('Enum with one constant (no args, not "none")', () async {
      const source = '''
enum MyEnum {
  alpha;
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), source.replaceAll(RegExp(r'\s+'), ' '));
    });
    
    test('Enum with one constant (with args, not "none")', () async {
      const source = '''
enum MyEnum {
  alpha(1);
}
''';
      final fixedCode = await _getFixedCode(source);
      expect(fixedCode?.replaceAll(RegExp(r'\s+'), ' '), source.replaceAll(RegExp(r'\s+'), ' '));
    });

  });
}

// --- Mocking/Helper classes (very simplified) ---
// In a real scenario, these would be provided by custom_lint_builder's test utilities
// or would need to be much more robust.

class _MockCustomLintContext implements CustomLintContext {
  @override
  final Map<Object?, Object?> sharedState = {};

  @override
  void reportLint(LintCode code, {List<Fix> fixes = const [], List<Object> arguments = const [], NodeLintRegistry? nodeRegistry, Location? location}) {
    // In a real test, this would collect reported lints
  }
  
  // Add other required methods from CustomLintContext if needed by the rule during testing,
  // potentially with default implementations or by throwing UnimplementedError.
  @override
  void addPostRunCallback(void Function() cb) => throw UnimplementedError();
  @override
  CustomLintConfigs get configs => throw UnimplementedError();
  @override
  List<String> get currentFileResolvedUnitPathParts => throw UnimplementedError();
  @override
  String get currentPackageRootPath => throw UnimplementedError();
  @override
  bool get isCurrentPackageRoot => throw UnimplementedError();
  @override
  List<String> get rootPackagePathParts => throw UnimplementedError();
  @override
  void addPreRunCallback(void Function() cb) => throw UnimplementedError();

  @override
  final NodeLintRegistry registry = NodeLintRegistry();
}

class _MockCustomLintResolver implements CustomLintResolver {
  final Uri _fileUri;
  final ParseStringResult _parseResult;

  _MockCustomLintResolver(this._fileUri, this._parseResult);

  @override
  Future<ResolvedUnitResult> getResolvedUnitResult() async {
    // This is a major simplification. A real resolver interacts with the analyzer.
    return ResolvedUnitResult(
      content: _parseResult.content,
      uri: _fileUri,
      unit: _parseResult.unit,
      errors: _parseResult.errors,
      libraryElement: _parseResult.unit.declaredElement!.library,
      lineInfo: _parseResult.lineInfo,
      isGenerated: false, 
      exists: true,
    );
  }
  
  // Add other required methods from CustomLintResolver
  @override
  Future<String> getFileContents() async => _parseResult.content;

  @override
  FileState get file => throw UnimplementedError();
}

class _MockChangeBuilder implements ChangeReporter {
  plugin.SourceFileEdit? sourceFileEdit;

  @override
  ChangeBuilder createChangeBuilder({required String message, required int priority}) {
    return _MockDartFileEditBuilder(this, message, priority);
  }
}

class _MockDartFileEditBuilder implements DartFileEditBuilder {
  final _MockChangeBuilder _reporter;
  // ignore: unused_field
  final String _message;
  // ignore: unused_field
  final int _priority;
  final List<plugin.SourceEdit> _edits = [];

  _MockDartFileEditBuilder(this._reporter, this._message, this._priority);

  @override
  void addSimpleReplacement(SourceRange range, String replacement) {
    _edits.add(plugin.SourceEdit(range.offset, range.length, replacement));
    _reporter.sourceFileEdit = plugin.SourceFileEdit(
      // Assuming a dummy file path, this should come from the resolver in a real scenario
      '/app/lib/src/rules/enum_constants_ordering_rule.dart', 
      0, // timestamp
      edits: _edits,
    );
  }
  
  // Implement other methods from DartFileEditBuilder as needed
  @override
  void addDeletion(SourceRange range) => throw UnimplementedError();
  @override
  void addFileEdit(SourceRange range, void Function(FileEditBuilder builder) buildFileEdit) => throw UnimplementedError();
  @override
  void addInsertion(int offset, String text) => throw UnimplementedError();
  @override
  void addLinkedEdit(String groupName, void Function(LinkedEditBuilder builder) buildLinkedEdit) => throw UnimplementedError();
  @override
  void addSimpleInsertion(int offset, String text) => throw UnimplementedError();
  @override
  void format(SourceRange range) { /* In a real test, this might re-parse and format */ }
  @override
  void formatAll(CompilationUnit unit) { /* In a real test, this might re-parse and format */ }
}

// Helper extension for RecordingErrorListener to adapt to AnalysisError
// This is needed because the rule reports AnalysisError via ErrorReporter,
// but the fix class might expect a different error type if not careful.
// However, our fix uses `AnalysisError` directly.
class RecordingErrorListener implements AnalysisErrorListener {
  final void Function(AnalysisError error) _onError;
  final List<AnalysisError> _errors = [];

  RecordingErrorListener(this._onError);

  List<AnalysisError> get errors => _errors;

  @override
  void onError(AnalysisError error) {
    _errors.add(error);
    _onError(error);
  }
}

// SourceRange for DartFileEditBuilder.addSimpleReplacement
class SourceRange {
  final int offset;
  final int length;
  SourceRange(this.offset, this.length);
}

// Location for CustomLintContext.reportLint (if needed, though our mock doesn't use it yet)
class Location {
  final String file;
  final int offset;
  final int length;
  final int startLine;
  final int startColumn;
  Location(this.file, this.offset, this.length, this.startLine, this.startColumn);
}

// LintCode for CustomLintContext.reportLint
// class LintCode {
//   final String name;
//   final String problemMessage;
//   final ErrorSeverity errorSeverity;
//   final String? correctionMessage;
//   final String? uniqueName;

//   const LintCode({
//     required this.name,
//     required this.problemMessage,
//     this.errorSeverity = ErrorSeverity.INFO,
//     this.correctionMessage,
//     String? uniqueName,
//   }) : uniqueName = uniqueName ?? name;
// }
