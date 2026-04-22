import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/enum/my_enums.dart';
import 'package:the_galvanometer_gallery/models/project_model.dart';
import 'package:the_galvanometer_gallery/providers/project_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       duration: const Duration(milliseconds: 1500),
       vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildHeader(),
          if (entries.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 150.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildInfographicHero(entries),
                  SizedBox(height: 48.h),
                  _buildInfographicSection('SENSITIVITY DISTRIBUTION', _buildSensitivityRows(entries)),
                  SizedBox(height: 40.h),
                  _buildInfographicSection('INSTRUMENT BREAKDOWN', _buildInstrumentTypeBreakdown(entries)),
                  SizedBox(height: 40.h),
                  _buildInfographicSection('MATERIAL INVENTORY', _buildMaterialDots(entries)),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.h, bottom: 24.h),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ARCHIVE INTELLIGENCE',
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Collection\nLogbook',
                style: GoogleFonts.cormorant(
                  color: kPrimaryText,
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfographicHero(List<GalvanometerModel> entries) {
    final total = entries.length;
    final goodCount = entries.where((e) => e.conditionState == ConditionState.pristine || e.conditionState == ConditionState.coilIntact || e.conditionState == ConditionState.restoredWorking).length;
    final healthFraction = total == 0 ? 0.0 : goodCount / total;

    return Column(
      children: [
        // Giant circular gauge for health
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              width: 240.w,
              height: 240.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(240.w, 240.w),
                    painter: _CircularGaugePainter(
                      progress: _animation.value * healthFraction,
                      color: kAccent,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_animation.value * healthFraction * 100).toInt()}%',
                        style: GoogleFonts.cormorant(color: kPrimaryText, fontSize: 64.sp, fontWeight: FontWeight.w700, height: 1.0),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'MUSEUM QUALITY',
                        style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 10.sp, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 40.h),
        // Simple data points row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDataStat(total.toString().padLeft(2, '0'), 'TOTAL'),
            _buildStatDivider(),
            _buildDataStat(_getYearRange(entries), 'ERA SPAN'),
            _buildStatDivider(),
            _buildDataStat(entries.map((e) => e.countryOfOrigin).toSet().length.toString(), 'NATIONS'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 32.h, color: kOutline);
  }

  Widget _buildDataStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(color: kPrimaryText, fontSize: 24.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 4.h),
        Text(label, style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 9.sp, letterSpacing: 1.0)),
      ],
    );
  }

  String _getYearRange(List<GalvanometerModel> entries) {
    final List<int> years = [];
    final regex = RegExp(r'\d{4}');
    for (var e in entries) {
      final matches = regex.allMatches(e.eraOfProduction);
      for (final m in matches) {
        final year = int.tryParse(m.group(0)!);
        if (year != null) years.add(year);
      }
    }
    if (years.isEmpty) return '—';
    years.sort();
    if (years.first == years.last) return years.first.toString();
    return '${years.first}–${years.last}';
  }

  Widget _buildInfographicSection(String title, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: kOutline)),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.jetBrainsMono(color: kAccent, fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 1.5),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Container(height: 1, color: kOutline)),
          ],
        ),
        SizedBox(height: 32.h),
        body,
      ],
    );
  }

  Widget _buildSensitivityRows(List<GalvanometerModel> entries) {
    final counts = <SensitivityClass, int>{};
    for (var e in entries) {
      counts[e.sensitivityClass] = (counts[e.sensitivityClass] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1 : sorted.first.value;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: sorted.map((item) {
            final fraction = (item.value / max) * _animation.value;
            final color = getSensitivityColor(item.key);
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.key.label, style: GoogleFonts.inter(color: kPrimaryText, fontSize: 14.sp)),
                      Text(item.value.toString().padLeft(2, '0'), style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CustomPaint(
                    size: Size(double.infinity, 4.h),
                    painter: _ProgressBarPainter(fraction: fraction, color: color),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInstrumentTypeBreakdown(List<GalvanometerModel> entries) {
    final counts = <InstrumentType, int>{};
    for (var e in entries) {
      counts[e.instrumentType] = (counts[e.instrumentType] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kOutline.withValues(alpha: 0.5)))),
          child: Row(
            children: [
              Icon(Icons.dashboard_customize_rounded, color: kSecondaryText.withValues(alpha: 0.3), size: 16.sp),
              SizedBox(width: 12.w),
              Expanded(child: Text(item.key.label, style: GoogleFonts.inter(color: kPrimaryText, fontSize: 15.sp))),
              Text(item.value.toString(), style: GoogleFonts.jetBrainsMono(color: kAccent, fontSize: 14.sp, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaterialDots(List<GalvanometerModel> entries) {
    final counts = <PrimaryMaterial, int>{};
    for (var e in entries) {
      counts[e.primaryMaterial] = (counts[e.primaryMaterial] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 12.w,
      runSpacing: 16.h,
      children: sorted.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: kOutline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.value.toString(), style: GoogleFonts.jetBrainsMono(color: kSecondaryAccent, fontSize: 12.sp, fontWeight: FontWeight.w700)),
              SizedBox(width: 8.w),
              Text(item.key.label, style: GoogleFonts.inter(color: kPrimaryText, fontSize: 13.sp)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('AWAITING DATA', style: GoogleFonts.jetBrainsMono(color: kSecondaryText, fontSize: 12.sp)),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  _CircularGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track
    final trackPaint = Paint()
      ..color = kOutline
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Active
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start top
      math.pi * 2 * progress,
      false,
      activePaint,
    );
    
    // Ticks layout
    final tickPaint = Paint()
      ..color = kSecondaryText.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    for (int i = 0; i < 72; i++) {
      final angle = (i * 2 * math.pi) / 72;
      canvas.drawLine(
        center + Offset(math.cos(angle) * (radius - 12), math.sin(angle) * (radius - 12)),
        center + Offset(math.cos(angle) * (radius - 4), math.sin(angle) * (radius - 4)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter old) => old.progress != progress;
}

class _ProgressBarPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _ProgressBarPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Track
    final trackPaint = Paint()
      ..color = kOutline
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), trackPaint);

    if (fraction > 0) {
      final activePaint = Paint()
        ..color = color
        ..strokeWidth = size.height
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, size.height/2), Offset(size.width * fraction, size.height/2), activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter old) => old.fraction != fraction;
}
