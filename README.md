# slide_countdown_clock

A Countdown clock with slide up and down animation plugin for Flutter

## Demo
![Demo: ](demo.gif)

## Usage
To use plugin, just import package `import 'package:slide_countdown_clock/slide_countdown_clock.dart';`

## Example
You can check example directory to know how to use it like the demo gif.

```
import 'package:flutter/material.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SlideCountdownClock(
                duration: Duration(seconds: 1000000),
                slideDirection: SlideDirection.Up,
                separator: ":",
                textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
                onDone: () {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Clock 1 finished')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
