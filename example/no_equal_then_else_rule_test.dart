// ignore_for_file: avoid_print, dead_code, unused_local_variable

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

  bool isProfessionalSelected = false;

  if (!isProfessionalSelected) {
    print(TripMotive.personal);
  } else {
    print(TripMotive.professional);
  }

  if (isProfessionalSelected) {
    print(TripMotive.personal);
  } else {
    print(TripMotive.professional);
  }
}

enum TripMotive { personal, professional }

extension TripMotiveExtensions on TripMotive {
  String get name => toString().split('.').last;
}
