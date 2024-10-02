void main1() {
  final map = {'hello': 'world'};

  map.keys.contains('hello'); // LINT
}

void main2() {
  final map = {'hello': 'world'};

  map.containsKey('hello');
}
