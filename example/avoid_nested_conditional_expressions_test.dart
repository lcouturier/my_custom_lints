final str = '';

final twoLevels = str.isEmpty
    ? str.isEmpty
        ? 'hi'
        : '1'
    : '2';

final threeLevels = str.isEmpty
    ? str.isEmpty // LINT: Avoid nested conditional expressions. Try rewriting the code to remove nesting.
        ? str.isEmpty // LINT: Avoid nested conditional expressions. Try rewriting the code to remove nesting.
            ? 'hi'
            : '1'
        : '2'
    : '3';
