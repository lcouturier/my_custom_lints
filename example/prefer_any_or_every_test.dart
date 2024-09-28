void fn() {
  final collection = [1, 2, 3, 4, 5];

  collection.where((item) => item.isEven).isNotEmpty; // LINT

  collection.where((item) => item.isEven).isEmpty; // LINT
  collection.where((item) => !item.isEven).isEmpty; // LINT

  collection.where((item) => true).isEmpty; // LINT

  collection.where((item) => item is String).isEmpty; // LINT
  collection.where((item) => item is! String).isEmpty; // LINT

  collection.where((item) => item == 4).isEmpty; // LINT
}
