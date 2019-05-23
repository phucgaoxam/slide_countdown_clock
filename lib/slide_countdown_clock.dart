library slide_countdown_clock;

import 'dart:async';
import 'package:flutter/material.dart';

part 'package:slide_countdown_clock/clip_digit.dart';

part 'package:slide_countdown_clock/digit.dart';

part 'package:slide_countdown_clock/slide_direction.dart';

class SlideCountdownClock extends StatefulWidget {
  final Duration duration;
  final TextStyle textStyle;
  final TextStyle separatorTextStyle;
  final String separator;
  final BoxDecoration decoration;
  final SlideDirection slideDirection;
  final VoidCallback onDone;
  final EdgeInsets padding;
  final bool tightLabel;

  SlideCountdownClock({
    Key key,
    @required this.duration,
    this.textStyle: const TextStyle(
      fontSize: 30,
      color: Colors.black,
    ),
    this.separatorTextStyle,
    this.decoration,
    this.tightLabel: false,
    this.separator: "",
    this.slideDirection: SlideDirection.Down,
    this.onDone,
    this.padding: EdgeInsets.zero,
  }) : super(key: key);

  @override
  SlideCountdownClockState createState() => SlideCountdownClockState();
}

class SlideCountdownClockState extends State<SlideCountdownClock> {
  Stream<DateTime> initStream;
  Duration timeLeft;
  Stream<DateTime> timeStream;

  @override
  void initState() {
    super.initState();

    timeLeft = widget.duration;
    _init();
  }

  @override
  void didUpdateWidget(SlideCountdownClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      timeLeft = widget.duration;
    } catch (ex) {}

    print('init');
    _init();
  }

  void _init() {
    var time = DateTime.now();
    initStream = Stream<DateTime>.periodic(Duration(milliseconds: 1000), (_) {
      timeLeft -= Duration(seconds: 1);
      if (timeLeft.inSeconds == 0) {
        Future.delayed(Duration(milliseconds: 1000), () {
          if (widget.onDone != null) widget.onDone();
        });
      }
      return time;
    });
    timeStream = initStream.take(timeLeft.inSeconds).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildDigit(
          timeStream,
          (DateTime time) => (timeLeft.inHours % 24) ~/ 10,
          (DateTime time) => (timeLeft.inHours % 24) % 10,
          DateTime.now(),
          "Hours",
        ),
        _buildSpace(),
        (widget.separator.isNotEmpty) ? _buildSeparator() : SizedBox(),
        _buildSpace(),
        _buildDigit(
          timeStream,
          (DateTime time) => (timeLeft.inMinutes % 60) ~/ 10,
          (DateTime time) => (timeLeft.inMinutes % 60) % 10,
          DateTime.now(),
          "minutes",
        ),
        _buildSpace(),
        (widget.separator.isNotEmpty) ? _buildSeparator() : SizedBox(),
        _buildSpace(),
        _buildDigit(
          timeStream,
          (DateTime time) => (timeLeft.inSeconds % 60) ~/ 10,
          (DateTime time) => (timeLeft.inSeconds % 60) % 10,
          DateTime.now(),
          "seconds",
        )
      ],
    );
  }

  Widget _buildSpace() {
    return SizedBox(width: 3);
  }

  Widget _buildSeparator() {
    return Text(
      widget.separator,
      style: widget.separatorTextStyle ?? widget.textStyle,
    );
  }

  Widget _buildDigit(
    Stream<DateTime> timeStream,
    Function tensDigit,
    Function onesDigit,
    DateTime startTime,
    String id,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: widget.decoration,
              padding: widget.tightLabel ? EdgeInsets.only(left: 3) : EdgeInsets.zero,
              child: Digit<int>(
                padding: widget.padding,
                itemStream: timeStream.map<int>(tensDigit),
                initValue: tensDigit(startTime),
                id: id,
                decoration: widget.decoration,
                slideDirection: widget.slideDirection,
                textStyle: widget.textStyle,
              ),
            ),
            Container(
              decoration: widget.decoration,
              padding: widget.tightLabel ? EdgeInsets.only(right: 3) : EdgeInsets.zero,
              child: Digit<int>(
                padding: widget.padding,
                itemStream: timeStream.map<int>(onesDigit),
                initValue: onesDigit(startTime),
                decoration: widget.decoration,
                slideDirection: widget.slideDirection,
                textStyle: widget.textStyle,
                id: id,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
