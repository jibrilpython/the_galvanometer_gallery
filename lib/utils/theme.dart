import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_galvanometer_gallery/utils/const.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: kAccent,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.light(
      primary: kAccent,
      secondary: kSecondaryAccent,
      surface: kPanelBg,
      onSurface: kPrimaryText,
      onPrimary: kPanelBg,
      error: kError,
      outline: kOutline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: kPrimaryText,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: kPrimaryText),
    ),
    textTheme: TextTheme(
      // ── Display — Cormorant (28px+ only) ────────────────────────────────────
      displayLarge: GoogleFonts.cormorant(
        fontSize: 56.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        height: 1.0,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.cormorant(
        fontSize: 44.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        height: 1.0,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.cormorant(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        color: kPrimaryText,
        letterSpacing: -0.5,
      ),
      // ── Headlines — Inter ───────────────────────────────────────────────────
      headlineLarge: GoogleFonts.inter(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: kPrimaryText,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: kPrimaryText,
        letterSpacing: -0.1,
      ),
      // ── Body — Inter (light weight) ─────────────────────────────────────────
      bodyLarge: GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: kPrimaryText,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        color: kPrimaryText,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w300,
        color: kSecondaryText,
      ),
      // ── Labels — JetBrains Mono (identifiers, specs) ────────────────────────
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: kPrimaryText,
        letterSpacing: 0.3,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: kSecondaryText,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: kSecondaryText,
        letterSpacing: 0.5,
      ),
      // ── Titles — Inter ───────────────────────────────────────────────────────
      titleLarge: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: kPrimaryText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: kPrimaryText,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: kSecondaryText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kPanelBg,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        borderSide: const BorderSide(color: kOutline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        borderSide: const BorderSide(color: kOutline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
        color: kSecondaryText.withValues(alpha: 0.5),
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
      ),
      labelStyle: GoogleFonts.inter(
        color: kSecondaryText,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: kAccent,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 32.w),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(kRadiusStandard)),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
          letterSpacing: 0.3,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: kOutline,
      thickness: 1.0,
      space: 0,
    ),
    useMaterial3: true,
  );
}
