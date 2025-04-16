import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension PopupExtension<T> on BuildContext {
  void showErrorSnackbar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  void showInfoSnackbar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(this).colorScheme.primary,
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  void showSuccessSnackbar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
