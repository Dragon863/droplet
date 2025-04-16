import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingStageThree extends StatelessWidget {
  const OnBoardingStageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(minHeight: 150, maxHeight: 250),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Image.asset('assets/ob-concepts.png'),
              ),
            ),
          ),
          Text(
            "Key Concepts",
            style: GoogleFonts.rubik(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "> Droplet consists of \"Bubbles\"; these are private groups of friends. Each bubble is a separate space.",
            style: GoogleFonts.inter(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "> In a bubble, there is a daily prompt chosen by a randomly chosen member.",
            style: GoogleFonts.inter(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "> You can reply to the prompt with text, and see the replies of others in the bubble.",
            style: GoogleFonts.inter(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
