// ignore_for_file: prefer_underscore_for_unused_callback_parameters, avoid_dynamic
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String myString = '';

  @override
  void initState() {
    super.initState();

    // LINT: Avoid calling unnecessary 'setState'. Try changing the state directly.
    setState(() {
      myString = "Hello";
    });

    if (true) {
      // LINT: Avoid calling unnecessary 'setState'. Try changing the state directly.
      setState(() {
        myString = "Hello";
      });
    }

    myStateUpdateMethod(); // LINT: Avoid calling sync methods that call 'setState'. Try changing the state directly.
  }

  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // LINT: Avoid calling unnecessary 'setState'. Try changing the state directly.
    setState(() {
      myString = "Hello";
    });
  }

  void myStateUpdateMethod() {
    setState(() {
      myString = "Hello";
    });
  }

  @override
  Widget build(BuildContext context) {
    // LINT: Avoid calling unnecessary 'setState'. Try changing the state directly.
    setState(() {
      myString = "Hello";
    });

    if (true) {
      // LINT: Avoid calling unnecessary 'setState'. Try changing the state directly.
      setState(() {
        myString = "Hello";
      });
    }

    myStateUpdateMethod(); // LINT: Avoid calling sync methods that call 'setState'. Try changing the state directly.

    return ElevatedButton(
      onPressed: () => myStateUpdateMethod(),
      onHover: (value) {
        setState(() {
          if (value) {
            myString = 'data';
          }
        });
      },
      onLongPress: () {
        setState(() {
          myString = 'data';
        });
      },
      child: Text('PRESS'),
    );
    // return MyTestWidget(onChange: () {
    //   setState(
    //     () {
    //       myString = 'data';
    //     },
    //   );
    // });
  }
}

class MyTestWidget extends StatefulWidget {
  const MyTestWidget({super.key, this.onChange});
  final Function()? onChange;

  @override
  State<MyTestWidget> createState() => _MyTestWidgetState();
}

class _MyTestWidgetState extends State<MyTestWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
