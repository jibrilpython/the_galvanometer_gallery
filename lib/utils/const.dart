import 'package:flutter/material.dart';
import 'package:the_galvanometer_gallery/enum/my_enums.dart';

// ─── COLOR PALETTE — "Laboratory Precision" ───────────────────────────────────
const Color kBackground      = Color(0xFFFAFAF8); // Laboratory white, barely warm
const Color kPrimaryText     = Color(0xFF141412); // Primary text & high-contrast
const Color kPanelBg         = Color(0xFFFFFFFF); // Secondary panels / card surfaces
const Color kSecondaryText   = Color(0xFF8C8C88); // Muted labels
const Color kAccent          = Color(0xFF2B5EA7); // Galvanometer blue — scientific ink
const Color kSecondaryAccent = Color(0xFFC17F24); // Brass instrument gold
const Color kOutline         = Color(0xFFEEECEA); // Stroke / dividers
const Color kError           = Color(0xFFC0392B); // Critical errors only

// ─── DERIVED COLORS ──────────────────────────────────────────────────────────
const Color kAccentLight     = Color(0xFF3A72C4);
const Color kAccentSurface   = Color(0xFFEEF2FA); // 10% blue tint
const Color kGoldSurface     = Color(0xFFF9F3E8); // 10% gold tint
const Color kGlassBackground = Color(0xB3FFFFFF); // 70% White

// ─── SENSITIVITY COLORS ───────────────────────────────────────────────────────
const Color kHighSensitivity  = Color(0xFF2B5EA7); // Blue — high-sensitivity (prized)
const Color kLowSensitivity   = Color(0xFFC17F24); // Gold — robust/common

// ─── SPACING ─────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ───────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSubtle   = 16.0; // Specimen cards (as per ui_rules)
const double kRadiusStandard = 24.0;
const double kRadiusMedium   = 32.0;
const double kRadiusLarge    = 40.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ─────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -4,
  color: Color(0x0C000000), // Lighter, more diffuse
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 16),
  blurRadius: 40,
  spreadRadius: -4,
  color: Color(0x14000000), // Softer floating shadow
);

const BoxShadow kShadowBlue = BoxShadow(
  offset: Offset(0, 12),
  blurRadius: 32,
  spreadRadius: -2,
  color: Color(0x202B5EA7), // More diffuse glow
);

// Stroke weights
const double kStrokeWeight       = 1.0;
const double kStrokeWeightMedium = 2.0;
const double kStrokeWeightThick  = 3.0; // 3px active border

// ─── SENSITIVITY CLASS COLOR ─────────────────────────────────────────────────
Color getSensitivityColor(SensitivityClass sc) {
  switch (sc) {
    case SensitivityClass.microammeterClass:
      return kHighSensitivity;
    case SensitivityClass.milliammeterClass:
      return kLowSensitivity;
    case SensitivityClass.ballistic:
      return const Color(0xFF4A7FB5);
    case SensitivityClass.mirrorOptical:
      return kHighSensitivity;
    case SensitivityClass.astatic:
      return const Color(0xFF6A8FCC);
    case SensitivityClass.other:
      return kSecondaryText;
  }
}

// ─── DEFLECTION ARC FRACTION (0.0 = shallow gold, 1.0 = full blue) ───────────
double getDeflectionFraction(SensitivityClass sc) {
  switch (sc) {
    case SensitivityClass.mirrorOptical:
      return 0.92;
    case SensitivityClass.microammeterClass:
      return 0.80;
    case SensitivityClass.astatic:
      return 0.70;
    case SensitivityClass.ballistic:
      return 0.55;
    case SensitivityClass.milliammeterClass:
      return 0.35;
    case SensitivityClass.other:
      return 0.20;
  }
}

// ─── CONDITION COLORS ─────────────────────────────────────────────────────────
Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.pristine:
      return kAccent;
    case ConditionState.coilIntact:
      return const Color(0xFF3A9E6A);
    case ConditionState.restoredWorking:
      return kSecondaryAccent;
    case ConditionState.minorWear:
      return kSecondaryText;
    case ConditionState.fiberBroken:
      return const Color(0xFFD4851A);
    case ConditionState.incomplete:
      return kError;
    case ConditionState.unknown:
      return kSecondaryText;
  }
}
