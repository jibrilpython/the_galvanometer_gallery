import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/models/project_model.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/providers/project_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen>
    with SingleTickerProviderStateMixin {
  String? _nodeAId;
  String? _nodeBId;
  late AnimationController _gyroController;

  @override
  void initState() {
    super.initState();
    _gyroController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _gyroController.dispose();
    super.dispose();
  }

  void _showSelectionSheet(BuildContext context, bool isNodeA) {
    final entries = ref.read(projectProvider).entries;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(kRadiusLarge),
            ),
            boxShadow: const [kShadowFloat],
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: kOutline,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'SELECT SPECIMEN ${isNodeA ? 'ALPHA' : 'BETA'}',
                style: GoogleFonts.jetBrainsMono(
                  color: kPrimaryText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child:
                    entries.isEmpty
                        ? Center(
                          child: Text(
                            'NO INSTRUMENTS AVAILABLE',
                            style: GoogleFonts.jetBrainsMono(
                              color: kSecondaryText,
                              fontSize: 11.sp,
                            ),
                          ),
                        )
                        : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: entries.length,
                          itemBuilder: (ctx, i) {
                            final e = entries[i];
                            final isDisabled =
                                (isNodeA && _nodeBId == e.id) ||
                                (!isNodeA && _nodeAId == e.id);
                            return GestureDetector(
                              onTap:
                                  isDisabled
                                      ? null
                                      : () {
                                        setState(() {
                                          if (isNodeA) {
                                            _nodeAId = e.id;
                                          } else {
                                            _nodeBId = e.id;
                                          }
                                        });
                                        Navigator.pop(ctx);
                                      },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(bottom: 10.h),
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color:
                                      isDisabled
                                          ? Colors.transparent
                                          : kPanelBg,
                                  borderRadius: BorderRadius.circular(
                                    kRadiusStandard,
                                  ),
                                  border: Border.all(
                                    color:
                                        (_nodeAId == e.id || _nodeBId == e.id)
                                            ? kAccent
                                            : kOutline,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.science_outlined,
                                      color:
                                          isDisabled
                                              ? kSecondaryText.withValues(
                                                alpha: 0.2,
                                              )
                                              : kAccent,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.manufacturer.isNotEmpty
                                                ? e.manufacturer
                                                : 'Unknown',
                                            style: GoogleFonts.inter(
                                              color:
                                                  isDisabled
                                                      ? kSecondaryText
                                                      : kPrimaryText,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            e.laboratoryIdentifier,
                                            style: GoogleFonts.jetBrainsMono(
                                              color: kSecondaryText,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;

    final nodeA =
        _nodeAId != null
            ? entries.cast<GalvanometerModel?>().firstWhere(
              (e) => e?.id == _nodeAId,
              orElse: () => null,
            )
            : null;
    final nodeB =
        _nodeBId != null
            ? entries.cast<GalvanometerModel?>().firstWhere(
              (e) => e?.id == _nodeBId,
              orElse: () => null,
            )
            : null;

    if ((_nodeAId != null && nodeA == null) ||
        (_nodeBId != null && nodeB == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (nodeA == null) {
            _nodeAId = null;
          }
          if (nodeB == null) {
            _nodeBId = null;
          }
        });
      });
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYMMETRIC ANALYSIS',
                        style: GoogleFonts.jetBrainsMono(
                          color: kAccent,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Compare',
                        style: GoogleFonts.cormorant(
                          color: kPrimaryText,
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  if (nodeA != null || nodeB != null)
                    GestureDetector(
                      onTap:
                          () => setState(() {
                            _nodeAId = null;
                            _nodeBId = null;
                          }),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: kPanelBg,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          border: Border.all(color: kOutline),
                        ),
                        child: Text(
                          'RESET',
                          style: GoogleFonts.jetBrainsMono(
                            color: kSecondaryText,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Selectors
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(child: _buildSelectorBlock(true, nodeA)),
                  SizedBox(width: 12.w),
                  Container(width: 1, height: 80.h, color: kOutline),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildSelectorBlock(false, nodeB)),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Comparison List
            Expanded(
              child:
                  (nodeA == null && nodeB == null)
                      ? _buildEmptyState()
                      : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 150.h),
                        children: [
                          _buildSymmetricRow(
                            'MAKER',
                            nodeA?.manufacturer,
                            nodeB?.manufacturer,
                          ),
                          _buildSymmetricRow(
                            'IDENTIFIER',
                            nodeA?.laboratoryIdentifier,
                            nodeB?.laboratoryIdentifier,
                          ),
                          _buildSymmetricRow(
                            'TYPE',
                            nodeA?.instrumentType.label,
                            nodeB?.instrumentType.label,
                          ),
                          _buildSymmetricRow(
                            'SENSITIVITY',
                            nodeA?.sensitivityClass.label,
                            nodeB?.sensitivityClass.label,
                          ),
                          _buildSymmetricRow(
                            'RESISTANCE',
                            nodeA?.internalResistance.isEmpty == false
                                ? '${nodeA!.internalResistance} Ω'
                                : null,
                            nodeB?.internalResistance.isEmpty == false
                                ? '${nodeB!.internalResistance} Ω'
                                : null,
                          ),
                          _buildSymmetricRow(
                            'ERA',
                            nodeA?.eraOfProduction,
                            nodeB?.eraOfProduction,
                          ),
                          _buildSymmetricRow(
                            'NATION',
                            nodeA?.countryOfOrigin,
                            nodeB?.countryOfOrigin,
                          ),
                          _buildSymmetricRow(
                            'CONDITION',
                            nodeA?.conditionState.label,
                            nodeB?.conditionState.label,
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorBlock(bool isNodeA, GalvanometerModel? node) {
    final imageProv = ref.watch(imageProvider);
    final imagePath =
        node != null ? imageProv.getImagePath(node.photoPath) : null;

    return GestureDetector(
      onTap: () {
        if (node != null) {
          setState(() => isNodeA ? _nodeAId = null : _nodeBId = null);
        } else {
          _showSelectionSheet(context, isNodeA);
        }
      },
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: node == null ? kPanelBg : kPrimaryText,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(
            color: node != null ? kAccent : kOutline,
            width: node != null ? 1.5 : 1,
          ),
          boxShadow: node != null ? const [kShadowSubtle] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child:
            node == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: kSecondaryText.withValues(alpha: 0.4),
                      size: 28.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'SELECT\n${isNodeA ? 'ALPHA' : 'BETA'}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                : Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imagePath != null && File(imagePath).existsSync())
                      Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.4),
                      ),
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: kAccent,
                              borderRadius: BorderRadius.circular(kRadiusPill),
                            ),
                            child: Text(
                              isNodeA ? 'ALPHA' : 'BETA',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            node.manufacturer.isEmpty
                                ? 'Unknown'
                                : node.manufacturer,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildSymmetricRow(String centerLabel, String? valA, String? valB) {
    if (valA == null && valB == null) return const SizedBox.shrink();

    final vA = valA?.isEmpty ?? true ? '—' : valA!;
    final vB = valB?.isEmpty ?? true ? '—' : valB!;
    final isDifferent =
        vA.trim().toLowerCase() != vB.trim().toLowerCase() &&
        vA != '—' &&
        vB != '—';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vA,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    color: isDifferent ? kAccent : kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: isDifferent ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    border: Border.all(color: kOutline),
                  ),
                  child: Text(
                    centerLabel,
                    style: GoogleFonts.jetBrainsMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  vB,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    color: isDifferent ? kSecondaryAccent : kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: isDifferent ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: kOutline),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _gyroController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(160.w, 160.w),
                painter: _GyroscopePainter(
                  rotation: _gyroController.value * 2 * math.pi,
                  color: kAccent,
                ),
              );
            },
          ),
          SizedBox(height: 48.h),
          Text(
            'AWAITING SPECIMENS',
            style: GoogleFonts.jetBrainsMono(
              color: kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'Select an Alpha and Beta specimen above to initiate a symmetrical analysis of their structural and historical properties.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GyroscopePainter extends CustomPainter {
  final double rotation;
  final Color color;

  _GyroscopePainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintBase =
        Paint()
          ..color = color.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final paintActive =
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Outer static ring
    canvas.drawCircle(center, radius, paintBase);

    // Ticks
    for (int i = 0; i < 24; i++) {
      final angle = (i * 2 * math.pi) / 24;
      final inner = radius - (i % 2 == 0 ? 8 : 4);
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        paintBase,
      );
    }

    // Inner rotating ellipses
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Ring 1
    canvas.rotate(rotation);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 1.5,
        height: radius * 0.4,
      ),
      paintActive,
    );

    // Ring 2 (counter rotating)
    canvas.rotate(-rotation * 2.5 + math.pi / 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 1.2,
        height: radius * 0.6,
      ),
      paintActive,
    );

    // Center core
    canvas.drawCircle(
      Offset.zero,
      3.w,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GyroscopePainter old) =>
      old.rotation != rotation;
}
