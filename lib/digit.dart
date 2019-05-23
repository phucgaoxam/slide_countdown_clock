part of slide_countdown_clock;

class Digit<T> extends StatefulWidget {
  final Stream<T> itemStream;
  final T initValue;
  final String id;
  final TextStyle textStyle;
  final BoxDecoration decoration;
  final SlideDirection slideDirection;
  final EdgeInsets padding;

  Digit({
    @required this.itemStream,
    @required this.initValue,
    @required this.id,
    @required this.textStyle,
    @required this.decoration,
    @required this.slideDirection,
    @required this.padding,
  });

  @override
  _DigitState createState() => _DigitState();
}

class _DigitState extends State<Digit> with SingleTickerProviderStateMixin {
  StreamSubscription<int> _streamSubscription;
  int _currentValue = 0;
  int _nextValue = 0;
  AnimationController _controller;

  bool haveData = false;

  Animatable<Offset> _slideDownDetails = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: Offset.zero,
  );
  Animation<Offset> _slideDownAnimation;

  Animatable<Offset> _slideDownDetails2 = Tween<Offset>(
    begin: const Offset(0.0, 0.0),
    end: Offset(0.0, 1.0),
  );
  Animation<Offset> _slideDownAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    _slideDownAnimation = _controller.drive(_slideDownDetails);
    _slideDownAnimation2 = _controller.drive(_slideDownDetails2);

   /* _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }

      if (status == AnimationStatus.dismissed) {
        _currentValue = _nextValue;
      }
    });

    _currentValue = widget.initValue;
    _streamSubscription = widget.itemStream.distinct().listen((value) {
      haveData = true;
      if (_currentValue == null) {
        _currentValue = value;
      } else if (value != _currentValue) {
        _nextValue = value;
        _controller.forward();
      }
    });*/
  }

  void animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reset();
    }

    if (status == AnimationStatus.dismissed) {
      _currentValue = _nextValue;
    }
  }

  @override
  void didUpdateWidget(Digit oldWidget) {
    super.didUpdateWidget(oldWidget);
    try {
      _controller.removeStatusListener(animationListener);
      _streamSubscription.cancel();
    } catch (ex) {

    }

    _controller.addStatusListener(animationListener);

    _currentValue = widget.initValue;
    _streamSubscription = widget.itemStream.distinct().listen((value) {
      haveData = true;
      if (_currentValue == null) {
        _currentValue = value;
      } else if (value != _currentValue) {
        _nextValue = value;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_streamSubscription != null) _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fakeWidget = Opacity(
      opacity: 0.0,
      child: Text(
        '9',
        style: widget.textStyle,
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
      ),
    );

    return Container(
      padding: widget.padding,
      alignment: Alignment.center,
      decoration: widget.decoration ?? BoxDecoration(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, w) {
          return Stack(
            fit: StackFit.passthrough,
            overflow: Overflow.clip,
            children: <Widget>[
              haveData
                  ? FractionalTranslation(
                      translation: (widget.slideDirection == SlideDirection.Down) ? _slideDownAnimation.value : -_slideDownAnimation.value,
                      child: ClipRect(
                        clipper: ClipHalfRect(
                          percentage: _slideDownAnimation.value.dy,
                          isUp: true,
                          slideDirection: widget.slideDirection,
                        ),
                        child: Text(
                          '$_nextValue',
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0,
                          style: widget.textStyle,
                        ),
                      ),
                    )
                  : SizedBox(),
              FractionalTranslation(
                translation: (widget.slideDirection == SlideDirection.Down) ? _slideDownAnimation2.value : -_slideDownAnimation2.value,
                child: ClipRect(
                  clipper: ClipHalfRect(
                    percentage: _slideDownAnimation2.value.dy,
                    isUp: false,
                    slideDirection: widget.slideDirection,
                  ),
                  child: Text(
                    '$_currentValue',
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                    style: widget.textStyle,
                  ),
                ),
              ),
              fakeWidget,
            ],
          );
        },
      ),
    );
  }
}
