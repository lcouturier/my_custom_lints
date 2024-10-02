void fn() {
  final x = 1;
  final a = 2;

  if (!(x == 1)) {} // LINT

  if (!(x != 1)) {} // LINT

  if (!(x > 1)) {} // LINT

  if (!(x < 1)) {} // LINT

  if (!(x >= 1)) {} // LINT

  if (!(x <= 1)) {} // LINT

  var b = !(x != 1) ? 1 : 2; // LINT

  var foo = !(x > 4); // LINT

  if (!(a > 4 && b < 2)) {}
}
