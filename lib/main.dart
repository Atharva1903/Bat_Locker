import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_screen.dart';
import 'utils/theme.dart';
import 'utils/responsive.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force google_fonts to use the locally-bundled TTF files in
  // assets/google_fonts/ instead of fetching from the internet at runtime.
  // Without this, the package silently falls back to the system default font
  // on devices without internet or when the CDN request fails.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BatLocker',
      theme: getAppTheme(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered Animations
  late Animation<double> _bgFade;
  late Animation<double> _glowFade;
  late Animation<double> _hudOpacity;
  late Animation<double> _hudRotation;
  late Animation<double> _scanLineY;
  late Animation<double> _emblemOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    // Total animation timeline: 3.3 seconds (3300ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3300),
    );

    // 0.0 - 0.5s: Fade in background and ambient glow
    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );
    _glowFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
      ),
    );

    // HUD rotates throughout
    _hudRotation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    // 0.5 - 1.5s: HUD opacity rises
    _hudOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeIn),
      ),
    );

    // 0.5 - 2.2s: Scanning line sweeps down and up
    _scanLineY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.67),
      ),
    );

    // 0.5 - 1.5s: Emblem fades in
    _emblemOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeIn),
      ),
    );

    // 1.5 - 2.7s: Titles fade in
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.82, curve: Curves.easeOut),
      ),
    );

    // 1.5 - 2.5s: One gentle pulse expansion
    _pulseGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.76, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Trigger redirect after 3.3 seconds with custom 200ms page fade transition (totalling 3.5 seconds)
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double hudSize = context.wp(60).clamp(180.0, 260.0);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black base
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _bgFade.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF141414), // Subtle dark gray inner
                    Color(0xFF0B0B0B), // Matte black outer
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft red ambient glow behind HUD
                  Positioned(
                    child: Container(
                      width: hudSize * 2.0,
                      height: hudSize * 2.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.5,
                          colors: [
                            kColorPrimary.withValues(alpha: 0.08 * _glowFade.value),
                            kColorPrimary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center Vector HUD & Emblem Custom Painter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: hudSize,
                        height: hudSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(hudSize, hudSize),
                              painter: HUDPainter(
                                rotation: _hudRotation.value,
                                emblemOpacity: _emblemOpacity.value,
                                hudOpacity: _hudOpacity.value,
                                scanLineY: _scanLineY.value,
                                pulse: _pulseGlow.value,
                                themeRed: kColorPrimary,
                              ),
                            ),
                            Opacity(
                              opacity: _emblemOpacity.value,
                              child: Image.asset(
                                'assets/images/bat_logo.png',
                                width: hudSize * 0.65,
                                height: hudSize * 0.65,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Text section (Fades in slowly at 1.2s)
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              'BAT LOCKER',
                              style: GoogleFonts.anton(
                                fontSize: context.sp(36),
                                color: Colors.white,
                                letterSpacing: 4.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Encrypted Password Manager',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: context.sp(11),
                                color: kColorNeutral,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HUDPainter extends CustomPainter {
  final double rotation;
  final double emblemOpacity;
  final double hudOpacity;
  final double scanLineY;
  final double pulse;
  final Color themeRed;

  HUDPainter({
    required this.rotation,
    required this.emblemOpacity,
    required this.hudOpacity,
    required this.scanLineY,
    required this.pulse,
    required this.themeRed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // HUD Circle 1: Outer Dash Ring (rotating clockwise)
    if (hudOpacity > 0) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      paint.color = themeRed.withValues(alpha: 0.3 * hudOpacity);
      _drawDashedCircle(canvas, Offset.zero, radius - 10, paint, 60);
      canvas.restore();
    }

    // HUD Circle 2: Middle Segmented Ring (rotating counter-clockwise)
    if (hudOpacity > 0) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-rotation * 0.7);
      paint.color = themeRed.withValues(alpha: 0.4 * hudOpacity);
      paint.strokeWidth = 1.5;
      _drawArcSegments(canvas, Offset.zero, radius - 22, paint);
      canvas.restore();
    }

    // HUD Circle 3: Inner Solid Thin Ring with ticks
    if (hudOpacity > 0) {
      paint.strokeWidth = 0.8;
      paint.color = themeRed.withValues(alpha: 0.2 * hudOpacity);
      canvas.drawCircle(center, radius - 35, paint);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation * 0.3);
      paint.color = themeRed.withValues(alpha: 0.5 * hudOpacity);
      _drawTicks(canvas, radius - 35, radius - 40, paint, 12);
      canvas.restore();
    }

    // Gentle Pulse effect (concentric ring spreading outwards)
    if (pulse > 0) {
      final pulseRadius = (radius - 35) + (pulse * (radius - 10 - (radius - 35)));
      final pulsePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = themeRed.withValues(alpha: 0.4 * (1.0 - pulse));
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }



    // Horizontal scanning line sweeping top to bottom within the HUD
    if (hudOpacity > 0 && scanLineY >= -1.0 && scanLineY <= 1.0) {
      final lineY = center.dy + (scanLineY * (radius - 12));
      final halfWidth = sqrt(max(0.0, (radius - 12) * (radius - 12) - (scanLineY * (radius - 12)) * (scanLineY * (radius - 12))));
      
      final scanPaint = Paint()
        ..color = themeRed.withValues(alpha: 0.8 * hudOpacity)
        ..strokeWidth = 1.2;

      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeRed.withValues(alpha: 0.25 * hudOpacity),
            themeRed.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(center.dx - halfWidth, lineY - 15, center.dx + halfWidth, lineY));

      canvas.drawRect(Rect.fromLTRB(center.dx - halfWidth, lineY - 15, center.dx + halfWidth, lineY), glowPaint);
      canvas.drawLine(Offset(center.dx - halfWidth, lineY), Offset(center.dx + halfWidth, lineY), scanPaint);
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint, int dashCount) {
    const double doublePi = 2 * pi;
    final double dashAngle = doublePi / dashCount;
    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  void _drawArcSegments(Canvas canvas, Offset center, double radius, Paint paint) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, 0.2, 1.2, false, paint);
    canvas.drawArc(rect, 2.2, 1.4, false, paint);
    canvas.drawArc(rect, 4.5, 1.1, false, paint);
  }

  void _drawTicks(Canvas canvas, double rStart, double rEnd, Paint paint, int tickCount) {
    final double step = 2 * pi / tickCount;
    for (int i = 0; i < tickCount; i++) {
      final double angle = i * step;
      final x1 = rStart * cos(angle);
      final y1 = rStart * sin(angle);
      final x2 = rEnd * cos(angle);
      final y2 = rEnd * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant HUDPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.emblemOpacity != emblemOpacity ||
        oldDelegate.hudOpacity != hudOpacity ||
        oldDelegate.scanLineY != scanLineY ||
        oldDelegate.pulse != pulse;
  }
}