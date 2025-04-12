import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme darkColourScheme = ColorScheme(
  brightness: Brightness.dark,
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
  surface: Color(0xFF181322),
  onSurface: Color(0xFFF2E7FF),
  // Containers
  primaryContainer: Color(0xFF221B33),
  onPrimaryContainer: Colors.white,
  // Tertiary
  tertiaryContainer: Color(0xFF221B33),
  onTertiaryContainer: Color(0xFFF2E7FF),
);

TextTheme darkTextTheme = GoogleFonts.interTextTheme().apply(
  displayColor: const Color(0xFFF2E7FF),
  bodyColor: const Color(0xFFBFA8D9),
);
