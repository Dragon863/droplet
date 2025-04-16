import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingStageOne extends StatelessWidget {
  const OnBoardingStageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 150, maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Image.asset('assets/logo-no-bg.png'),
              ),
            ),
          ),
          Text(
            "Welcome!",
            style: GoogleFonts.rubik(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "Let's get started with Droplet, a simpler, less addictive way to connect with your friends.",
            style: GoogleFonts.inter(fontSize: 16),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
