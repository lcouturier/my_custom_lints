void fn() {
  final list = [1, 2, 3];

  if (list.indexOf(1) ==
      -1) {} // LINT: Prefer '.contains' instead of '.indexOf' when checking for the presence of an element.
  if (list.indexOf(1) !=
      -1) {} // LINT: Prefer '.contains' instead of '.indexOf' when checking for the presence of an element.

  if (list.indexOf(2) ==
      1) {} // LINT: Prefer '.contains' instead of '.indexOf' when checking for the presence of an element.
}
