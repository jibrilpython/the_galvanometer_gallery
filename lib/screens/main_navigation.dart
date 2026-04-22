import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_galvanometer_gallery/screens/home_screen.dart';
import 'package:the_galvanometer_gallery/screens/compare_screen.dart';
import 'package:the_galvanometer_gallery/screens/stats_screen.dart';
import 'package:the_galvanometer_gallery/screens/showcase_screen.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int index;
  const MainNavigation({super.key, this.index = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  final List<Widget> _screens = const [
    HomeScreen(),
    CompareScreen(),
    ShowcaseScreen(),
    StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 20.h + MediaQuery.of(context).padding.bottom,
            child: _buildNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusPill),
        boxShadow: const [kShadowFloat],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: kPrimaryText.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(0, Icons.auto_stories_rounded, 'Gallery'),
              _buildNavItem(1, Icons.compare_rounded, 'Compare'),
              _buildNavItem(2, Icons.scatter_plot_rounded, 'Field Map'),
              _buildNavItem(3, Icons.bar_chart_rounded, 'Logbook'),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18.w : 14.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35),
              size: 20.sp,
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
