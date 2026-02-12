import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  late AnimationController pulseController;
  late Animation<double> scaleAnimation;

  late AnimationController sparkleController;
  late AnimationController balloonController;

  double pulseSpeed = 1.0;
  bool showBalloons = false;

void initState() {
    super.initState();

    pulseController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    scaleAnimation = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    sparkleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    balloonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  void togglePulse() {
    if (pulseController.isAnimating) {
      pulseController.stop();
    } else {
      pulseController.repeat(reverse: true);
    }
  }

  void triggerBalloons() {
    setState(() => showBalloons = true);
    balloonController.forward(from: 0);
  }

  @override
  void dispose() {
    pulseController.dispose();
    sparkleController.dispose();
    balloonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Column(
  children: [
    const SizedBox(height: 16),

    DropdownButton<String>(
      value: selectedEmoji,
      items: emojiOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) =>
          setState(() => selectedEmoji = value ?? selectedEmoji),
    ),

    const SizedBox(height: 10),

    ElevatedButton(
      onPressed: togglePulse,
      child: const Text("Pulse ❤️"),
    ),

    // ✅ MOVE SLIDER HERE (outside Stack)
    Slider(
      value: pulseSpeed,
      min: 0.5,
      max: 2,
      onChanged: (val) {
        setState(() {
          pulseSpeed = val;
          pulseController.duration =
              Duration(milliseconds: (800 / pulseSpeed).round());
        });
      },
    ),

    Expanded(
      child: AnimatedBuilder(
        animation: sparkleController,
        builder: (_, __) {
          return Stack(
            children: [
              Center(
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: HeartEmojiPainter(
                      type: selectedEmoji,
                      sparkleValue: sparkleController.value,
                    ),
                  ),
                ),
              ),

              if (showBalloons)
                AnimatedBuilder(
                  animation: balloonController,
                  builder: (_, __) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: BalloonPainter(
                        progress: balloonController.value,),
                    );
                  },
                ),
            ],
          );
        },
      ),
    ),
  ],
      ),);
}

}
class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type,required this.sparkleValue,});
  final String type;
  final double sparkleValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60,
          center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110,
          center.dy - 10, center.dx, center.dy + 60)
      ..close();

   
    final auraPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    canvas.drawPath(heartPath, auraPaint);


    final gradient = LinearGradient(
      colors: type == 'Party Heart'
          ? [Colors.pinkAccent, Colors.orange]
          : [Colors.red, Colors.pinkAccent],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
          Rect.fromCenter(center: center, width: 200, height: 200));

    canvas.drawPath(heartPath, paint);


    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      pi,
      false,
      mouthPaint,
    );

    /// ✅ PARTY HEART EXTRAS
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      drawConfetti(canvas, size);
    }

    drawSparkles(canvas, center);
  }

  void drawConfetti(Canvas canvas, Size size) {
    final rand = Random(1);

    for (int i = 0; i < 20; i++) {
      final paint =
          Paint()..color = Colors.primaries[i % Colors.primaries.length];

      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;

      if (i % 2 == 0) {
        canvas.drawCircle(Offset(dx, dy), 4, paint);
      } else {
        final path = Path()
          ..moveTo(dx, dy)
          ..lineTo(dx + 6, dy)
          ..lineTo(dx + 3, dy - 6)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void drawSparkles(Canvas canvas, Offset center) {
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + sparkleValue * 2 * pi;
      final dx = center.dx + cos(angle) * 120;
      final dy = center.dy + sin(angle) * 120;

      canvas.drawCircle(Offset(dx, dy), 3, sparklePaint);
      canvas.drawLine(
          Offset(dx - 5, dy), Offset(dx + 5, dy), sparklePaint);
      canvas.drawLine(
          Offset(dx, dy - 5), Offset(dx, dy + 5), sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.sparkleValue != sparkleValue;
}

class BalloonPainter extends CustomPainter {
  final double progress;

  BalloonPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.pink, Colors.purple];

    for (int i = 0; i < 6; i++) {
      final paint = Paint()..color = colors[i % colors.length];

      final dx = (i + 1) * size.width / 7;
      final dy = size.height - (progress * size.height);

      canvas.drawOval(
        Rect.fromCenter(center: Offset(dx, dy), width: 40, height: 60),
        paint,
      );

      canvas.drawLine(
        Offset(dx, dy + 30),
        Offset(dx, dy + 80),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) =>
      oldDelegate.progress != progress;
}