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
      onLongPress: () {
        setState(() {
          myString = 'data';
        });
      },
      child: Text('PRESS'),
    );
  }
}
