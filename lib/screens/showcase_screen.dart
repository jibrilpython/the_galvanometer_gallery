import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_galvanometer_gallery/enum/my_enums.dart';
import 'package:the_galvanometer_gallery/models/project_model.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/providers/project_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';

// ─── Physics Constants ────────────────────────────────────────────────────────
const double kRepulsion    = 18000.0;
const double kSpringLength = 180.0;
const double kSpringK      = 0.06;
const double kDamping      = 0.88;
const double kMaxVelocity  = 12.0;

// ─── Node ─────────────────────────────────────────────────────────────────────
class _FieldNode {
  final GalvanometerModel model;
  final int index;
  final SensitivityClass sensitivityClass;
  Offset pos;
  Offset vel;
  bool isPinned = false;
  bool isExcited = false;

  _FieldNode({
    required this.model,
    required this.index,
    required this.sensitivityClass,
    required this.pos,
    this.vel = Offset.zero,
  });

  double get nodeRadius {
    final deflection = getDeflectionFraction(sensitivityClass);
    return 22.0 + deflection * 14.0;
  }
}

// ─── Field Pulse ──────────────────────────────────────────────────────────────
class _FieldPulse {
  Offset origin;
  double radius;
  double opacity;
  final Color color;

  _FieldPulse({required this.origin, required this.color})
      : radius = 0,
        opacity = 0.7;

  bool get isDead => opacity <= 0.0;

  void tick() {
    radius += 4.0;
    opacity -= 0.018;
  }
}

// ─── Showcase Screen ──────────────────────────────────────────────────────────
class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final TransformationController _transformCtrl = TransformationController();

  final List<_FieldNode> _nodes = [];
  final List<_FieldPulse> _pulses = [];

  bool _isBuilt = false;
  int _lastHash = -1;
  _FieldNode? _focusedNode;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_nodes.isEmpty) return;

    final dt = 1.0;

    // Apply repulsion between all nodes
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].isPinned) continue;
      Offset force = Offset.zero;

      for (int j = 0; j < _nodes.length; j++) {
        if (i == j) continue;
        final delta = _nodes[i].pos - _nodes[j].pos;
        final dist = delta.distance.clamp(1.0, 800.0);
        final repel = kRepulsion / (dist * dist);
        force += delta / dist * repel;
      }

      // Spring attraction for same sensitivity class
      for (int j = 0; j < _nodes.length; j++) {
        if (i == j) continue;
        if (_nodes[i].sensitivityClass == _nodes[j].sensitivityClass) {
          final delta = _nodes[j].pos - _nodes[i].pos;
          final dist = delta.distance.clamp(1.0, 800.0);
          final stretch = dist - kSpringLength;
          final spring = kSpringK * stretch;
          force += delta / dist * spring;
        }
      }

      // Gravity towards centre
      final centre = Offset(2000, 2000);
      final toCentre = centre - _nodes[i].pos;
      force += toCentre * 0.0008;

      _nodes[i].vel = (_nodes[i].vel + force * dt) * kDamping;
      final speed = _nodes[i].vel.distance;
      if (speed > kMaxVelocity) {
        _nodes[i].vel = _nodes[i].vel / speed * kMaxVelocity;
      }
      _nodes[i].pos += _nodes[i].vel * dt;
    }

    // Advance pulses
    for (int i = _pulses.length - 1; i >= 0; i--) {
      _pulses[i].tick();
      if (_pulses[i].isDead) _pulses.removeAt(i);
    }

    setState(() {});
  }

  void _buildFieldMap(List<GalvanometerModel> entries) {
    final currentHash = Object.hash(
      ref.read(projectProvider).stateVersion,
      entries.length,
    );
    if (_isBuilt && _lastHash == currentHash) return;

    _isBuilt = true;
    _lastHash = currentHash;
    _nodes.clear();
    _pulses.clear();

    if (entries.isEmpty) return;

    final rand = math.Random(42);
    for (int i = 0; i < entries.length; i++) {
      final angle = (i / entries.length) * math.pi * 2;
      final radius = 200.0 + rand.nextDouble() * 200;
      final pos = Offset(
        2000 + math.cos(angle) * radius,
        2000 + math.sin(angle) * radius,
      );
      _nodes.add(_FieldNode(
        model: entries[i],
        index: i,
        sensitivityClass: entries[i].sensitivityClass,
        pos: pos,
        vel: Offset(
          (rand.nextDouble() - 0.5) * 2,
          (rand.nextDouble() - 0.5) * 2,
        ),
      ));
    }

    // Centre view on field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewSize = MediaQuery.of(context).size;
      const centre = Offset(2000, 2000);
      final dx = (viewSize.width / 2) - centre.dx;
      final dy = (viewSize.height / 2) - centre.dy;
      _transformCtrl.value = Matrix4.identity()
        ..setTranslationRaw(dx, dy, 0);
    });
  }

  void _exciteNode(_FieldNode node) {
    if (_focusedNode != null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      node.isExcited = !node.isExcited;
      _pulses.add(_FieldPulse(
        origin: node.pos,
        color: getSensitivityColor(node.sensitivityClass),
      ));
      // Impulse velocity
      if (node.isExcited) {
        final impulseAngle = math.Random().nextDouble() * math.pi * 2;
        node.vel = Offset(
          math.cos(impulseAngle) * 6,
          math.sin(impulseAngle) * 6,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    _buildFieldMap(entries);

    return Scaffold(
      backgroundColor: kBackground,
      body: entries.isEmpty ? _buildEmptyState() : _buildFieldView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'NO INSTRUMENTS IN THIS GALLERY.',
        style: GoogleFonts.jetBrainsMono(
          color: kSecondaryText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildFieldView() {
    const mapSize = 4000.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Physics canvas ────────────────────────────────────────────────
        InteractiveViewer(
          transformationController: _transformCtrl,
          boundaryMargin: const EdgeInsets.all(mapSize),
          minScale: 0.08,
          maxScale: 2.5,
          constrained: false,
          child: SizedBox(
            width: mapSize,
            height: mapSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _FieldPainter(
                        nodes: _nodes,
                        pulses: _pulses,
                      ),
                    ),
                  ),
                ),
                ..._nodes.map((n) => _buildNode(n)),
              ],
            ),
          ),
        ),

        // ── HUD ───────────────────────────────────────────────────────────
        _buildHUD(),

        // ── Focus card ────────────────────────────────────────────────────
        if (_focusedNode != null) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _focusedNode = null),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                    color: Colors.black.withValues(alpha: 0.12)),
              ),
            ),
          ),
          _buildFocusCard(),
        ],
      ],
    );
  }

  Widget _buildNode(_FieldNode node) {
    final radius = node.nodeRadius;
    final color = getSensitivityColor(node.sensitivityClass);
    final deflection = getDeflectionFraction(node.sensitivityClass);

    return Positioned(
      left: node.pos.dx - radius,
      top: node.pos.dy - radius,
      width: radius * 2,
      height: radius * 2,
      child: GestureDetector(
        onPanStart: (_) {
          node.isPinned = true;
        },
        onPanUpdate: (d) {
          setState(() {
            node.pos += d.delta;
            node.vel = Offset.zero;
          });
        },
        onPanEnd: (_) {
          node.isPinned = false;
          _exciteNode(node);
        },
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _focusedNode = node);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: node.isExcited
                ? color
                : kPanelBg,
            border: Border.all(
              color: color,
              width: node.isExcited ? 3.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: node.isExcited ? 0.5 : 0.15),
                blurRadius: node.isExcited ? 20 : 8,
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: Size(radius * 1.2, radius * 1.2),
              painter: _NodeArcPainter(
                fraction: deflection,
                color: node.isExcited ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16.h,
      left: 20.w,
      right: 20.w,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SENSITIVITY FIELD MAP',
              style: GoogleFonts.jetBrainsMono(
                color: kAccent,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              'Electromagnetic\nField',
              style: GoogleFonts.cormorant(
                color: kPrimaryText,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: kPanelBg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kOutline),
              ),
              child: Text(
                'DRAG NODES · TAP TO FOCUS · PINCH TO ZOOM',
                style: GoogleFonts.jetBrainsMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard() {
    final entry = _focusedNode!.model;
    final imgPath =
        ref.watch(imageProvider).getImagePath(entry.photoPath);
    final sensColor = getSensitivityColor(entry.sensitivityClass);
    final deflection = getDeflectionFraction(entry.sensitivityClass);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 60.0, end: 0.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        return Positioned(
          bottom: 100.h + val,
          left: 20.w,
          right: 20.w,
          child: child!,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline),
          boxShadow: const [kShadowFloat],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instrument photo strip
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(kRadiusStandard)),
              child: SizedBox(
                height: 160.h,
                width: double.infinity,
                child: (imgPath != null && File(imgPath).existsSync())
                    ? Image.file(File(imgPath), fit: BoxFit.cover)
                    : Container(
                        color: kBackground,
                        child: Center(
                          child: CustomPaint(
                            size: Size(80.w, 48.h),
                            painter: _NodeArcPainter(
                              fraction: deflection,
                              color: sensColor,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: kAccentSurface,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                        ),
                        child: Text(
                          entry.sensitivityClass.label,
                          style: GoogleFonts.inter(
                            color: sensColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (entry.internalResistance.isNotEmpty)
                        Text(
                          '${entry.internalResistance} Ω',
                          style: GoogleFonts.jetBrainsMono(
                            color: kSecondaryText,
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer
                        : 'Unknown Maker',
                    style: GoogleFonts.cormorant(
                      color: kPrimaryText,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.laboratoryIdentifier,
                    style: GoogleFonts.jetBrainsMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Action button
            GestureDetector(
              onTap: () {
                final idx = _focusedNode!.index;
                setState(() => _focusedNode = null);
                Navigator.pushNamed(
                  context,
                  '/info_screen',
                  arguments: {'index': idx},
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(kRadiusStandard)),
                ),
                child: Center(
                  child: Text(
                    'OPEN SPECIMEN RECORD',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field Painter (grid + spring edges + pulse rings) ─────────────────────────
class _FieldPainter extends CustomPainter {
  final List<_FieldNode> nodes;
  final List<_FieldPulse> pulses;

  _FieldPainter({required this.nodes, required this.pulses});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle dot-grid
    final dotPaint = Paint()
      ..color = kOutline.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 60) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    // 2. Spring edges between same-class nodes
    final edgePaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if (nodes[i].sensitivityClass == nodes[j].sensitivityClass) {
          final color = getSensitivityColor(nodes[i].sensitivityClass);
          edgePaint.color = color.withValues(alpha: 0.18);
          canvas.drawLine(nodes[i].pos, nodes[j].pos, edgePaint);
        }
      }
    }

    // 3. Pulse rings
    for (final pulse in pulses) {
      final pulsePaint = Paint()
        ..color = pulse.color.withValues(alpha: pulse.opacity.clamp(0.0, 1.0))
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pulse.origin, pulse.radius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FieldPainter old) => true;
}

// ─── Node Arc Painter ──────────────────────────────────────────────────────────
class _NodeArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _NodeArcPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) * 0.8;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * fraction,
      false,
      activePaint,
    );

    // Needle
    final angle = math.pi + math.pi * fraction;
    canvas.drawLine(
      center,
      center +
          Offset(math.cos(angle) * radius * 0.9, math.sin(angle) * radius * 0.9),
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _NodeArcPainter old) =>
      old.fraction != fraction || old.color != color;
}
