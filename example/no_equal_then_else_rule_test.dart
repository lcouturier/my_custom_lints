void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  if (_valueA == 1) {
    _result = _valueA;
  } else {
    _result = _valueA;
  }

  if (_valueA == 1) {
    _result = _valueA;
  } else {
    _result = _valueB;
  }

  _result = _valueA == 2 ? _valueA : _valueA;

  _result = _valueA == 2 ? _valueA : _valueB;
}
