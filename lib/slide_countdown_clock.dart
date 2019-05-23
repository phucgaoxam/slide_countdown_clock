library slide_countdown_clock;

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  final bool shouldShowDays;

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
    this.shouldShowDays: false,
    this.padding: EdgeInsets.zero,
  }) : super(key: key);

  @override
  SlideCountdownClockState createState() =>
      SlideCountdownClockState(duration, shouldShowDays);
}

class SlideCountdownClockState extends State<SlideCountdownClock> {
  SlideCountdownClockState(Duration duration, bool shouldShowDays) {
    timeLeft = duration;
    this.shouldShowDays = shouldShowDays;

    if (timeLeft.inHours > 99) {
      this.shouldShowDays = true;
    }
  }

  bool shouldShowDays;
  Duration timeLeft;
  Stream<DateTime> timeStream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    var time = DateTime.now();
    final initStream =
        Stream<DateTime>.periodic(Duration(milliseconds: 1000), (_) {
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
    Widget dayDigits;
    if (timeLeft.inDays > 99) {
      List<Function> digits = [];
      for (int i = timeLeft.inDays.toString().length - 1; i >= 0; i--) {
        digits.add((DateTime time) =>
            ((timeLeft.inDays) ~/ math.pow(10, i) % math.pow(10, 1)).toInt());
      }
      dayDigits = _buildDigitForLargeNumber(
          timeStream, digits, DateTime.now(), 'daysHundreds');
    } else {
      dayDigits = _buildDigit(
        timeStream,
        (DateTime time) => (timeLeft.inDays) ~/ 10,
        (DateTime time) => (timeLeft.inDays) % 10,
        DateTime.now(),
        "Days",
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        (shouldShowDays) ? dayDigits : SizedBox(),
        (shouldShowDays) ? _buildSpace() : SizedBox(),
        (widget.separator.isNotEmpty && shouldShowDays)
            ? _buildSeparator()
            : SizedBox(),
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

  Widget _buildDigitForLargeNumber(
    Stream<DateTime> timeStream,
    List<Function> digits,
    DateTime startTime,
    String id,
  ) {
    String timeLeftString = timeLeft.inDays.toString();
    List<Widget> rows = [];
    for (int i = 0; i < timeLeftString.toString().length; i++) {
      rows.add(
        Container(
          decoration: widget.decoration,
          padding:
              widget.tightLabel ? EdgeInsets.only(left: 3) : EdgeInsets.zero,
          child: Digit<int>(
            padding: widget.padding,
            itemStream: timeStream.map<int>(digits[i]),
            initValue: digits[i](startTime),
            id: id,
            decoration: widget.decoration,
            slideDirection: widget.slideDirection,
            textStyle: widget.textStyle,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: rows,
        ),
      ],
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
              padding: widget.tightLabel
                  ? EdgeInsets.only(left: 3)
                  : EdgeInsets.zero,
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
              padding: widget.tightLabel
                  ? EdgeInsets.only(right: 3)
                  : EdgeInsets.zero,
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
