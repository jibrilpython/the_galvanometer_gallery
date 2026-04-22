import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/providers/project_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusMedium),
            border: Border.all(color: kOutline, width: 1),
            boxShadow: const [kShadowFloat],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: kError.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: kError, size: 28.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                'REMOVE FROM ARCHIVE',
                style: GoogleFonts.jetBrainsMono(
                  color: kPrimaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'This specimen will be permanently removed from the gallery. This cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius:
                              BorderRadius.circular(kRadiusStandard),
                          border: Border.all(color: kOutline),
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.jetBrainsMono(
                              color: kSecondaryText,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(projectProvider).deleteEntry(index);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: kError,
                          borderRadius:
                              BorderRadius.circular(kRadiusStandard),
                        ),
                        child: Center(
                          child: Text(
                            'REMOVE',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final index = args['index'] as int;

    final projectProv = ref.watch(projectProvider);
    if (index >= projectProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Specimen not found.')),
      );
    }

    final entry = projectProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final deflection = getDeflectionFraction(entry.sensitivityClass);
    final sensColor = getSensitivityColor(entry.sensitivityClass);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Large hero header ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.42,
            stretch: true,
            backgroundColor: kPrimaryText,
            leadingWidth: 72.w,
            leading: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _showDeleteDialog(context, ref, index),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 20.sp),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  ref.read(projectProvider).fillInput(ref, index);
                  Navigator.pushNamed(
                    context,
                    '/add_screen',
                    arguments: {'index': index, 'isEdit': true},
                  );
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Icon(Icons.edit_rounded,
                      color: Colors.white, size: 18.sp),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'item-$index',
                child: (entry.photoPath.isNotEmpty &&
                        imagePath != null &&
                        File(imagePath).existsSync())
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF1A2A3A),
                        child: Center(
                          child: Icon(
                            Icons.science_outlined,
                            color: Colors.white.withValues(alpha: 0.15),
                            size: 80.sp,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // ── Detail cards ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusLarge)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type pill + era
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: kAccentSurface,
                            borderRadius:
                                BorderRadius.circular(kRadiusPill),
                            border: Border.all(
                                color: kAccent.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            entry.instrumentType.label,
                            style: GoogleFonts.inter(
                              color: kAccent,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (entry.eraOfProduction.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: kGoldSurface,
                              borderRadius:
                                  BorderRadius.circular(kRadiusPill),
                              border: Border.all(
                                  color: kSecondaryAccent.withValues(
                                      alpha: 0.25)),
                            ),
                            child: Text(
                              entry.eraOfProduction,
                              style: GoogleFonts.jetBrainsMono(
                                color: kSecondaryAccent,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Instrument name (Cormorant at 32+)
                    Text(
                      entry.manufacturer.isNotEmpty
                          ? entry.manufacturer
                          : 'Unknown Maker',
                      style: GoogleFonts.cormorant(
                        color: kPrimaryText,
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      entry.laboratoryIdentifier,
                      style: GoogleFonts.jetBrainsMono(
                        color: kSecondaryText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // ── Sensitivity arc visualization ──────────────────
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: kPanelBg,
                        borderRadius:
                            BorderRadius.circular(kRadiusStandard),
                        border: Border.all(color: kOutline),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80.w,
                            height: 56.h,
                            child: CustomPaint(
                              painter: _InfoArcPainter(
                                fraction: deflection,
                                color: sensColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.sensitivityClass.label.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: sensColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (entry.internalResistance.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    '${entry.internalResistance} Ω',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: kPrimaryText,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'COIL RESISTANCE',
                                    style: GoogleFonts.inter(
                                      color: kSecondaryText,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // ── Technical specs ────────────────────────────────
                    _buildSectionHeader('TECHNICAL SPECIFICATION'),
                    SizedBox(height: 16.h),
                    _buildSpecRow('Operating Principle',
                        entry.operatingPrinciple.label),
                    _buildSpecRow(
                        'Country of Origin', entry.countryOfOrigin),
                    _buildSpecRow('Primary Material',
                        entry.primaryMaterial.label),
                    _buildSpecRow('Condition', entry.conditionState.label),
                    if (entry.sensitivityAndScale.isNotEmpty)
                      _buildSpecRow('Sensitivity & Scale',
                          entry.sensitivityAndScale),
                    if (entry.dimensionsAndWeight.isNotEmpty)
                      _buildSpecRow(
                          'Dimensions', entry.dimensionsAndWeight),

                    if (entry.markingsAndEngravings.isNotEmpty) ...[
                      SizedBox(height: 28.h),
                      _buildSectionHeader('MARKINGS & ENGRAVINGS'),
                      SizedBox(height: 12.h),
                      _buildMonoBox(entry.markingsAndEngravings),
                    ],

                    if (entry.includedAccessories.isNotEmpty) ...[
                      SizedBox(height: 28.h),
                      _buildSectionHeader('INCLUDED ACCESSORIES'),
                      SizedBox(height: 12.h),
                      _buildMonoBox(entry.includedAccessories),
                    ],

                    if (entry.provenance.isNotEmpty) ...[
                      SizedBox(height: 28.h),
                      _buildSectionHeader('PROVENANCE'),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: kAccentSurface,
                          borderRadius:
                              BorderRadius.circular(kRadiusStandard),
                          border: Border.all(
                              color: kAccent.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          entry.provenance,
                          style: GoogleFonts.inter(
                            color: kAccent,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    if (entry.notes.isNotEmpty) ...[
                      SizedBox(height: 28.h),
                      _buildSectionHeader('ARCHIVAL NOTES'),
                      SizedBox(height: 12.h),
                      Text(
                        entry.notes,
                        style: GoogleFonts.inter(
                          color: kPrimaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                          height: 1.65,
                        ),
                      ),
                    ],

                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3.w, height: 14.h, color: kAccent),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            color: kPrimaryText,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonoBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          color: kPrimaryText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Arc painter for info screen ───────────────────────────────────────────────
class _InfoArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _InfoArcPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) * 0.9;

    final bgPaint = Paint()
      ..color = kOutline
      ..strokeWidth = 2.0
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
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * fraction,
      false,
      activePaint,
    );

    final angle = math.pi + math.pi * fraction;
    canvas.drawLine(
      center,
      center +
          Offset(math.cos(angle) * radius * 0.85,
              math.sin(angle) * radius * 0.85),
      Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _InfoArcPainter old) =>
      old.fraction != fraction;
}
