// ignore_for_file: avoid_single_child_column_or_row
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      // LINT
      children: [
        Container(),
        Container(),
      ],
    );
  }
}
