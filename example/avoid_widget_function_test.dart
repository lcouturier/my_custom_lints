// ignore_for_file: avoid_single_child_column_or_row, prefer_underscore_for_unused_callback_parameters
import 'package:flutter/material.dart';

Container buildContainer() {
  return Container();
}

class AvoidWidgetFunctionTest {
  Widget get widget => const Row();

  Widget buildWidget() {
    return Container();
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget();

  // LINT: Avoid returning widgets from a getter. Try replacing this getter with a stateless widget.
  Widget get _someWidget => Container();

  Widget _buildShinyWidget() {
    return Container(
      child: Column(
        children: [
          Text('Hello'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Text!'),
        _buildShinyWidget(),
        _buildShinyWidget(),
      ],
    );
  }
}
