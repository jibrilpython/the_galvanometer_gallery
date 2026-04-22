import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/enum/my_enums.dart';
import 'package:the_galvanometer_gallery/models/project_model.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/providers/input_provider.dart';
import 'package:the_galvanometer_gallery/providers/project_provider.dart';
import 'package:the_galvanometer_gallery/providers/search_provider.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  SensitivityClass? _selectedFilter;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final allEntries = ref.watch(projectProvider).entries;

    final filterText = searchProv.searchQuery.toLowerCase();
    List<GalvanometerModel> entries =
        allEntries.where((e) {
          final matchesSearch =
              filterText.isEmpty ||
              e.manufacturer.toLowerCase().contains(filterText) ||
              e.laboratoryIdentifier.toLowerCase().contains(filterText) ||
              e.instrumentType.label.toLowerCase().contains(filterText);

          final matchesFilter =
              _selectedFilter == null || e.sensitivityClass == _selectedFilter;

          return matchesSearch && matchesFilter;
        }).toList();

    final isDefaultView =
        _searchController.text.isEmpty && _selectedFilter == null;
    final carouselEntries =
        isDefaultView ? entries.take(3).toList() : <GalvanometerModel>[];
    final listEntries = isDefaultView ? entries.skip(3).toList() : entries;

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildHeader(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 20.h),
                      _buildSensitivityFilter(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              if (entries.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (isDefaultView &&
                          index == 0 &&
                          carouselEntries.isNotEmpty) {
                        return _buildFeaturedCarousel(
                          carouselEntries,
                          allEntries,
                        );
                      }

                      final itemIndex =
                          (isDefaultView && carouselEntries.isNotEmpty)
                              ? index - 1
                              : index;
                      if (itemIndex < 0 || itemIndex >= listEntries.length) {
                        return const SizedBox.shrink();
                      }

                      final entry = listEntries[itemIndex];
                      final mainIndex = allEntries.indexOf(entry);
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                        child: _buildListCard(context, entry, mainIndex),
                      );
                    },
                    childCount:
                        (isDefaultView && carouselEntries.isNotEmpty)
                            ? listEntries.length + 1
                            : listEntries.length,
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 150.h)),
            ],
          ),
          Positioned(
            right: 20.w,
            bottom: 110.h + MediaQuery.of(context).padding.bottom,
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        ref.read(inputProvider).clearAll();
        ref.read(imageProvider).clearImage();
        Navigator.pushNamed(context, '/add_screen');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusPill),
          boxShadow: const [kShadowBlue],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                // color: kAccent.withValues(alpha: 0.85),
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'ADD SPECIMEN',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24.h,
        bottom: 16.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE ARCHIVE',
                style: GoogleFonts.jetBrainsMono(
                  color: kSecondaryText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.5,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Galvanometer\nGallery',
                      style: GoogleFonts.cormorant(
                        color: kPrimaryText,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w700,
                        height: 0.92,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: kAccentSurface,
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                      border: Border.all(color: kAccent.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      count.toString().padLeft(2, '0'),
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
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

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowSubtle],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
        style: GoogleFonts.inter(
          color: kPrimaryText,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search makers or lab IDs...',
          hintStyle: GoogleFonts.inter(
            color: kSecondaryText.withValues(alpha: 0.5),
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isFocused ? kAccent : kSecondaryText,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).setSearchQuery('');
                    },
                    child: Icon(Icons.close_rounded, color: kSecondaryText),
                  )
                  : null,
          filled: true,
          fillColor: kPanelBg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusStandard),
            borderSide: const BorderSide(color: kOutline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusStandard),
            borderSide: const BorderSide(color: kAccent, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildSensitivityFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(null, 'ALL'),
          ...SensitivityClass.values.map((s) => _buildFilterChip(s, s.label)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(SensitivityClass? sensitivity, String label) {
    final isSelected = _selectedFilter == sensitivity;
    final color =
        sensitivity != null ? getSensitivityColor(sensitivity) : kPrimaryText;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = sensitivity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(
            color: isSelected ? color : kOutline,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            if (sensitivity != null) ...[
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              label.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? color : kSecondaryText,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 80.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.science_outlined,
              size: 64.sp,
              color: kSecondaryText.withValues(alpha: 0.2),
            ),
            SizedBox(height: 16.h),
            Text(
              'No specimens found matching criteria.',
              style: GoogleFonts.inter(color: kSecondaryText, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(
    List<GalvanometerModel> entries,
    List<GalvanometerModel> allEntries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
          child: Row(
            children: [
              Icon(Icons.view_carousel_outlined, color: kAccent, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'FEATURED SPECIMENS',
                style: GoogleFonts.jetBrainsMono(
                  color: kPrimaryText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 440.h,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final mainIndex = allEntries.indexOf(entry);
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double pageOffset = 0.0;
                  if (_pageController.position.haveDimensions) {
                    pageOffset = _pageController.page! - index;
                  }

                  double tilt = pageOffset.clamp(-1.0, 1.0);
                  double depth = 1.0 - (tilt.abs() * 0.15);

                  final matrix =
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(tilt * -0.5)
                        ..scaleByDouble(depth, depth, 1.0, 1.0);

                  return Center(
                    child: Transform(
                      transform: matrix,
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 440.h,
                        width: 320.w,
                        child: Opacity(
                          opacity: (1.0 - (tilt.abs() * 0.5)).clamp(0.0, 1.0),
                          child: _buildCarouselCard(
                            context,
                            entry,
                            mainIndex,
                            pageOffset,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double page = 0.0;
            if (_pageController.position.haveDimensions) {
              page = _pageController.page ?? 0.0;
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(entries.length, (index) {
                final isSelected = (page.round() == index);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 6.h,
                  width: isSelected ? 32.w : 6.w,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? kAccent : kOutline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3.h),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: kAccent.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                            : null,
                  ),
                );
              }),
            );
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildCarouselCard(
    BuildContext context,
    GalvanometerModel entry,
    int mainIndex,
    double parallaxOffset,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final sensColor = getSensitivityColor(entry.sensitivityClass);
    final deflection = _getDeflectionFraction(entry.sensitivityClass);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/info_screen',
          arguments: {'index': mainIndex},
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(40.w),
          boxShadow: const [kShadowFloat],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'img-$mainIndex',
              child:
                  (imagePath != null && File(imagePath).existsSync())
                      ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        alignment: Alignment(parallaxOffset * 0.8, 0.0),
                      )
                      : Center(
                        child: Icon(
                          Icons.science_outlined,
                          color: kSecondaryText.withValues(alpha: 0.1),
                          size: 80.sp,
                        ),
                      ),
            ),
            Positioned.fill(child: CustomPaint(painter: _ReticlePainter())),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.2),
                    radius: 0.85,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.3, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer[0].toUpperCase()
                        : 'X',
                    style: GoogleFonts.cormorant(
                      color: Colors.white.withValues(alpha: 0.05),
                      fontSize: 100.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: sensColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                    child: Text(
                      entry.sensitivityClass.label.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    entry.manufacturer.isNotEmpty
                        ? entry.manufacturer
                        : 'Unknown Maker',
                    style: GoogleFonts.cormorant(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 32.w,
                        height: 20.h,
                        child: CustomPaint(
                          painter: _DeflectionArcPainter(
                            fraction: deflection,
                            color: sensColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          entry.laboratoryIdentifier,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    GalvanometerModel entry,
    int mainIndex,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final sensColor = getSensitivityColor(entry.sensitivityClass);
    final deflection = _getDeflectionFraction(entry.sensitivityClass);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/info_screen',
          arguments: {'index': mainIndex},
        );
      },
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline, width: 1),
          boxShadow: const [kShadowSubtle],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 120.w,
              height: double.infinity,
              child: Hero(
                tag: 'img_list-$mainIndex',
                child:
                    (imagePath != null && File(imagePath).existsSync())
                        ? Image.file(File(imagePath), fit: BoxFit.cover)
                        : Container(
                          color: kBackground,
                          child: Center(
                            child: Icon(
                              Icons.science_outlined,
                              color: kSecondaryText.withValues(alpha: 0.1),
                              size: 40.sp,
                            ),
                          ),
                        ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.laboratoryIdentifier.isNotEmpty
                          ? entry.laboratoryIdentifier.toUpperCase()
                          : '—',
                      style: GoogleFonts.jetBrainsMono(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      entry.manufacturer.isNotEmpty
                          ? entry.manufacturer
                          : 'Unknown Maker',
                      style: GoogleFonts.inter(
                        color: kPrimaryText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 16.h,
                          child: CustomPaint(
                            painter: _DeflectionArcPainter(
                              fraction: deflection,
                              color: sensColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            entry.instrumentType.label,
                            style: GoogleFonts.inter(
                              color: kSecondaryText,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getDeflectionFraction(SensitivityClass sensitivity) {
    switch (sensitivity) {
      case SensitivityClass.ballistic:
        return 1.0;
      case SensitivityClass.astatic:
        return 0.85;
      case SensitivityClass.mirrorOptical:
        return 0.6;
      case SensitivityClass.microammeterClass:
        return 0.4;
      case SensitivityClass.milliammeterClass:
        return 0.2;
      case SensitivityClass.other:
        return 0.0;
    }
  }
}

class _DeflectionArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _DeflectionArcPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final basePaint =
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      basePaint,
    );

    final activePaint =
        Paint()
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

    final needlePaint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final angle = math.pi + math.pi * fraction;
    final needleEnd =
        center +
        Offset(
          math.cos(angle) * (radius * 0.9),
          math.sin(angle) * (radius * 0.9),
        );
    canvas.drawLine(center, needleEnd, needlePaint);

    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DeflectionArcPainter old) =>
      old.fraction != fraction;
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;

    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final double length = 20.0;
    final double margin = 24.0;

    // Top Left
    canvas.drawLine(
      Offset(margin, margin + length),
      Offset(margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + length, margin),
      paint,
    );

    // Top Right
    canvas.drawLine(
      Offset(size.width - margin - length, margin),
      Offset(size.width - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + length),
      paint,
    );

    // Bottom Left
    canvas.drawLine(
      Offset(margin, size.height - margin - length),
      Offset(margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + length, size.height - margin),
      paint,
    );

    // Bottom Right
    canvas.drawLine(
      Offset(size.width - margin - length, size.height - margin),
      Offset(size.width - margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter old) => false;
}
