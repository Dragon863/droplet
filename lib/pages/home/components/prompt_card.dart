import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptCard extends StatelessWidget {
  final String text;
  const PromptCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            VerticalSpacer(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            VerticalSpacer(height: 12),
          ],
        ),
      ),
    );
  }
}
