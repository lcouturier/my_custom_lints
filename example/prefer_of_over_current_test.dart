import 'package:flutter/widgets.dart';

// class I18n {
//   I18n._();

//   static I18n? _instance = null;

//   static I18n get current {
//     if (_instance == null) {
//       _instance = I18n._();
//     }

//     return _instance!;
//   }

//   // ignore: unused_parameter
//   static I18n of(BuildContext context) {
//     return I18n.current;
//   }

//   String external_link_srLabel = 'external_link';
// }

class I18n {
  static I18n? _instance;
  // Avoid self instance
  I18n._();
  static I18n get current => _instance ??= I18n._();

  String get external_link_srLabel => 'external_link';

  // ignore: unused_parameter
  static I18n of(BuildContext context) => I18n.current;

  void insodeFn(BuildContext ctx) {
    final value = I18n.current.external_link_srLabel;
    // ignore: avoid_print
    print(value);
  }
}

void fn(BuildContext context) {
  final value = I18n.current.external_link_srLabel;
  // ignore: avoid_print
  print(value);
}

void withoutContext() {
  final value = I18n.current.external_link_srLabel;
  // ignore: avoid_print
  print(value);
}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildMywidget();
  }

  Widget _buildMywidget() {
    final value = I18n.current.external_link_srLabel;
    return Text(value);
  }
}
