class Dog {
  final String? _name;

  const Dog(this._name);

  String getName() {
    print(_name);
    return _name ?? '';
  }
}
