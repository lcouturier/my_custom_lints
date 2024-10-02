void fn() {
  final x = 1;
  final a = 2;

  final z = x == 1 ? null : true;
  if (!(z ?? false)) {}
  if (!(z ?? true)) {}
  if (z ?? true) {}

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
