import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // LINT
        children: [..._items()],
      ),
    );
  }

  List<Widget> _items() {
    return [Container()];
  }
}
