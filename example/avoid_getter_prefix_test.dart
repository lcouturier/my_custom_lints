// ignore_for_file: boolean_prefixes
abstract class ModalRoute {
  bool get getBarrierDismissible; // LINT
}

class Some implements ModalRoute {
  @override
  bool get getBarrierDismissible => false;
}
