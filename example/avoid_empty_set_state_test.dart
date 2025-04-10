// ignore_for_file: prefer_underscore_for_unused_callback_parameters, avoid_unconditional_break
import 'package:flutter/widgets.dart';

class FooState extends State<StatefulWidget> {
  Widget build(context) {
    return FooWidget(
      onChange: (value) {
        // LINT: Avoid calling 'setState' with an empty callback. Try updating the callback or removing this invocation.
        setState(() {});
      },
    );
  }
}

class FooWidget extends StatefulWidget {
  const FooWidget({super.key, required this.onChange});

  final ValueChanged<bool> onChange;

  @override
  State<FooWidget> createState() => _FooWidgetState();
}

class _FooWidgetState extends State<FooWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
