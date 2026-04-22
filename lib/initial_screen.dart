import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/providers/user_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _calibrationController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       duration: const Duration(milliseconds: 2000),
       vsync: this,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine)
    );

    _calibrationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _calibrationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        ref.read(userProvider).setFirstTimeUser(false);
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _calibrationController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    HapticFeedback.lightImpact();
    _calibrationController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_calibrationController.status != AnimationStatus.completed) {
      if (_calibrationController.value > 0.92) {
        // Inertia snap to finish
        _calibrationController.forward();
      } else {
        _calibrationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Background subtle noise or gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [kPanelBg, kBackground],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              child: Column(
                children: [
                  // Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: kOutline, width: 1),
                            borderRadius: BorderRadius.circular(kRadiusPill),
                            color: kPanelBg,
                          ),
                          child: Text(
                            'TGG',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13.sp,
                              color: kAccent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'The',
                          style: GoogleFonts.cormorant(
                            color: kSecondaryText,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Galvanometer\nGallery.',
                          style: GoogleFonts.cormorant(
                            color: kPrimaryText,
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w700,
                            height: 0.92,
                            letterSpacing: -1.0,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          width: 48.w,
                          height: 1,
                          color: kAccent.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Calibration Lens Interaction
                  Listener(
                    onPointerDown: _onPointerDown,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: (_) => _onPointerUp(const PointerUpEvent()),
                    child: ScaleTransition(
                      scale: _pulseScale,
                      child: AnimatedBuilder(
                        animation: _calibrationController,
                        builder: (context, child) {
                          final progress = _calibrationController.value;
                          return Container(
                            width: 240.w,
                            height: 240.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPanelBg,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.lerp(
                                    kShadowFloat.color,
                                    kAccent.withValues(alpha: 0.3),
                                    progress,
                                  )!,
                                  blurRadius: 32 + (progress * 24),
                                  spreadRadius: progress * 8,
                                )
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: Size(200.w, 200.w),
                                  painter: _CalibrationGaugePainter(
                                    progress: progress,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fingerprint_rounded,
                                      size: 40.sp,
                                      color: Color.lerp(kSecondaryText, kAccent, progress),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      (progress * 100).toInt() == 100 
                                      ? 'CALIBRATED' 
                                      : 'HOLD TO INITIALISE',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Color.lerp(kPrimaryText, kAccent, progress),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  // Footer copy
                  Text(
                    'Precision instruments require a steady hand.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorant(
                      color: kSecondaryText,
                      fontSize: 18.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CalibrationGaugePainter extends CustomPainter {
  final double progress;
  _CalibrationGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track
    final trackPaint = Paint()
      ..color = kOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, trackPaint);

    // Dynamic ticks
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashCount = 36;
    for (int i = 0; i < dashCount; i++) {
      final angle = ((i * 2 * math.pi) / dashCount) - (math.pi / 2);
      final isActivated = (i / dashCount) <= progress;
      final innerRadius = radius - (isActivated ? 8 : 4);
      
      tickPaint.color = isActivated ? kAccent : kOutline;
      
      canvas.drawLine(
        center + Offset(math.cos(angle) * innerRadius, math.sin(angle) * innerRadius),
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        tickPaint,
      );
    }

    // Active arc
    if (progress > 0) {
      final activePaint = Paint()
        ..color = kAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start at top
        math.pi * 2 * progress,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalibrationGaugePainter old) => old.progress != progress;
}
