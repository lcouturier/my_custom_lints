// LINT: Avoid nested records. Try rewriting the code to remove nesting.
typedef NullableRecord = ((({String str, Future<void> hello}),),);

// LINT: Avoid nested records. Try rewriting the code to remove nesting.
(int, (int, (int,))) triple() => (1, (1, (1,)));

typedef CustomeRecord = (int, (int, (int,)));
