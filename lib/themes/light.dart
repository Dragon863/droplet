import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme lightColourScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary
  primary: Color(0xFF9B51E0),
  onPrimary: Colors.white,
  // Secondary
  secondary: Color(0xFFB37DFF),
  onSecondary: Colors.white,
  // Error
  error: Colors.red,
  onError: Colors.white,
  // Background
  surface: Color(0xFFF8F6FB),
  onSurface: Color(0xFF2E1A47),
  // Containers
  primaryContainer: Color(0xFF9B51E0),
  onPrimaryContainer: Colors.white,
  // Tertiary
  tertiaryContainer: Color(0xFFECE6F5),
  onTertiaryContainer: Color(0xFF2E1A47),
);

TextTheme lightTextTheme = GoogleFonts.interTextTheme().apply(
  displayColor: const Color(0xFF2E1A47),
  bodyColor: const Color(0xFF5C486E),
);
