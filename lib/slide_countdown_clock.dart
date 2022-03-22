library slide_countdown_clock;

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

part 'package:slide_countdown_clock/clip_digit.dart';

part 'package:slide_countdown_clock/digit.dart';

part 'package:slide_countdown_clock/slide_direction.dart';

class SlideCountdownClock extends StatefulWidget {
  /// The amount of time until the event and `onDone` is called.
  final Duration duration;

  /// The style of text used for the digits
  final TextStyle textStyle;

  /// The style used for seperator between digits. I.e. `:`, `.`, `,`.
  final TextStyle? separatorTextStyle;

  /// The character(s) to display between the hour divisions: `10 : 20`
  final String separator;

  /// The decoration to place on the container
  final BoxDecoration? decoration;

  /// The direction in which the numerals move out in and out of view.
  final SlideDirection slideDirection;

  /// A callback that is called when the [duration] reaches 0.
  final VoidCallback? onDone;

  /// The padding around the widget.
  final EdgeInsets padding;

  /// True for a label that needs added padding between characters.
  final bool tightLabel;

  /// Whether the widget should show another division for days.
  final bool shouldShowDays;

  /// Whether the widget should show another division for hours.
  final bool shouldShowHours;

  const SlideCountdownClock({
    Key? key,
    required this.duration,
    this.textStyle = const TextStyle(
      fontSize: 30,
      color: Colors.black,
    ),
    this.separatorTextStyle,
    this.decoration,
    this.tightLabel = false,
    this.separator = "",
    this.slideDirection = SlideDirection.down,
    this.onDone,
    this.shouldShowDays = false,
    this.shouldShowHours = true,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  SlideCountdownClockState createState() => SlideCountdownClockState();
}

class SlideCountdownClockState extends State<SlideCountdownClock> {
  late bool shouldShowDays;
  late bool shouldShowHours;
  late Duration timeLeft;
  late Stream<DateTime> initStream;
  Stream<DateTime>? timeStream;

  @override
  void initState() {
    super.initState();
    timeLeft = widget.duration;
    shouldShowDays = widget.shouldShowDays;
    shouldShowHours = widget.shouldShowHours;
    if (timeLeft.inHours > 99) {
      shouldShowDays = true;
      shouldShowHours = true;
    }
    if (timeLeft.inMinutes > 59) {
      shouldShowHours = true;
    }
    _init();
  }

  @override
  void didUpdateWidget(SlideCountdownClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      timeLeft = widget.duration;
    } catch (ex) {}

    _init();
  }

  void _init() {
    final time = DateTime.now();
    initStream =
        Stream<DateTime>.periodic(const Duration(milliseconds: 1000), (_) {
      timeLeft -= const Duration(seconds: 1);
      if (timeLeft.inSeconds == 0) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (widget.onDone != null && mounted) widget.onDone!();
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
      final List<Function> digits = [];
      for (int i = timeLeft.inDays.toString().length - 1; i >= 0; i--) {
        digits.add((DateTime time) =>
            ((timeLeft.inDays) ~/ math.pow(10, i) % math.pow(10, 1)).toInt());
      }
      dayDigits = _buildDigitForLargeNumber(
          timeStream, digits, DateTime.now(), 'daysHundreds');
    } else {
      dayDigits = _buildDigit(
        timeStream!,
        (DateTime time) => (timeLeft.inDays) ~/ 10,
        (DateTime time) => (timeLeft.inDays) % 10,
        DateTime.now(),
        "Days",
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (shouldShowDays) dayDigits else const SizedBox(),
        if (shouldShowDays) _buildSpace() else const SizedBox(),
        if (widget.separator.isNotEmpty && shouldShowDays)
          _buildSeparator()
        else
          const SizedBox(),
        if (shouldShowHours)
          _buildDigit(
            timeStream!,
            (DateTime time) => shouldShowDays
                ? (timeLeft.inHours % 24) ~/ 10
                : timeLeft.inHours ~/ 10,
            (DateTime time) => shouldShowDays
                ? (timeLeft.inHours % 24) % 10
                : timeLeft.inHours % 10,
            DateTime.now(),
            "Hours",
          )
        else
          const SizedBox(),
        _buildSpace(),
        if (widget.separator.isNotEmpty && shouldShowHours)
          _buildSeparator()
        else
          const SizedBox(),
        _buildSpace(),
        _buildDigit(
          timeStream!,
          (DateTime time) => (timeLeft.inMinutes % 60) ~/ 10,
          (DateTime time) => (timeLeft.inMinutes % 60) % 10,
          DateTime.now(),
          "minutes",
        ),
        _buildSpace(),
        if (widget.separator.isNotEmpty)
          _buildSeparator()
        else
          const SizedBox(),
        _buildSpace(),
        _buildDigit(
          timeStream!,
          (DateTime time) => (timeLeft.inSeconds % 60) ~/ 10,
          (DateTime time) => (timeLeft.inSeconds % 60) % 10,
          DateTime.now(),
          "seconds",
        )
      ],
    );
  }

  Widget _buildSpace() {
    return const SizedBox(width: 3);
  }

  Widget _buildSeparator() {
    return Text(
      widget.separator,
      style: widget.separatorTextStyle ?? widget.textStyle,
    );
  }

  Widget _buildDigitForLargeNumber(
    Stream<DateTime>? timeStream,
    List<Function> digits,
    DateTime startTime,
    String id,
  ) {
    final String timeLeftString = timeLeft.inDays.toString();
    final List<Widget> rows = [];
    for (int i = 0; i < timeLeftString.toString().length; i++) {
      rows.add(
        Container(
          decoration: widget.decoration,
          padding: widget.tightLabel
              ? const EdgeInsets.only(left: 3)
              : EdgeInsets.zero,
          child: Digit<int?>(
            padding: widget.padding,
            itemStream:
                timeStream!.map<int>(digits[i] as int Function(DateTime)),
            initValue: digits[i](startTime) as int,
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
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: widget.decoration,
              padding: widget.tightLabel
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(left: 3),
              child: Digit<int?>(
                padding: widget.padding,
                itemStream:
                    timeStream.map<int>(tensDigit as int Function(DateTime)),
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
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 3),
              child: Digit<int?>(
                padding: widget.padding,
                itemStream:
                    timeStream.map<int>(onesDigit as int Function(DateTime)),
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
