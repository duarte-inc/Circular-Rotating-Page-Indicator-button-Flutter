import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

var pageCounter = 0;
bool forwardRollDone = false;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  double get indicatorGap => pi / 12;

  double get indicatorLength => pi / 3;

  Animation animation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    animation = Tween(begin: 0.0, end: !forwardRollDone ? 2 * pi : (-2 * pi))
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.easeIn));

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reset();
      }
    });
  }

  fillindicator() {
    animation = Tween(begin: 0.0, end: !forwardRollDone ? 2 * pi : (-2 * pi))
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    if (!forwardRollDone) {
      pageCounter += 1;
      if (pageCounter == 2) {
        forwardRollDone = true;
      }
    } else {
      pageCounter -= 1;
      if (pageCounter == 0) {
        forwardRollDone = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return OnboardingPageIndicator(
          indicatorLength: indicatorLength,
          indicatorGap: indicatorGap,
          angle: animation.value,
          child: NextButton(
            onPressed: () {
              setState(() {
                fillindicator();
                animationController.forward();
              });
            },
          ),
        );
      },
    );
  }
}

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator(
      {Key key,
      @required this.indicatorLength,
      @required this.indicatorGap,
      @required this.child,
      @required this.angle})
      : super(key: key);

  final double indicatorLength;
  final double indicatorGap;
  final double angle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Center(
        child: Container(
          height: 70,
          width: 70,
          child: CustomPaint(
            painter: CustomIndicatorArcPainter(
                color: pageCounter >= 0
                    ? Colors.deepOrange.withOpacity(1)
                    : Colors.deepOrange.withOpacity(0.2),
                startAngle: (4 * indicatorLength) -
                    (indicatorLength + indicatorGap) +
                    angle,
                indicatorLength: indicatorLength),
            child: CustomPaint(
              painter: CustomIndicatorArcPainter(
                  color: pageCounter >= 1
                      ? Colors.deepOrange.withOpacity(1)
                      : Colors.deepOrange.withOpacity(0.2),
                  startAngle: (4 * indicatorLength) + angle,
                  indicatorLength: indicatorLength),
              child: CustomPaint(
                painter: CustomIndicatorArcPainter(
                    color: pageCounter >= 2
                        ? Colors.deepOrange.withOpacity(1)
                        : Colors.deepOrange.withOpacity(0.2),
                    startAngle: (4 * indicatorLength) +
                        (indicatorLength + indicatorGap) +
                        angle,
                    indicatorLength: indicatorLength),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final Function onPressed;

  const NextButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RawMaterialButton(
        padding: EdgeInsets.all(16),
        elevation: 10,
        onPressed: onPressed,
        shape: CircleBorder(),
        fillColor: Colors.deepOrange.withOpacity(1),
        child: Icon(
          !forwardRollDone ? Icons.arrow_forward : Icons.arrow_back,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CustomIndicatorArcPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double indicatorLength;

  const CustomIndicatorArcPainter({
    @required this.color,
    @required this.startAngle,
    @required this.indicatorLength,
  })  : assert(color != null),
        assert(startAngle != null),
        assert(indicatorLength != null);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.shortestSide + 12.0) / 2,
      ),
      startAngle,
      indicatorLength,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomIndicatorArcPainter oldDelegate) {
    return this.color != oldDelegate.color ||
        this.startAngle != oldDelegate.startAngle;
  }
}
