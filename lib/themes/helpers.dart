import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyText extends StatelessWidget {
  final String text;
  const BodyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onTertiaryContainer,
      ),
    );
  }
}

class HeadingText extends StatelessWidget {
  final String text;
  const HeadingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class SubheadingText extends StatelessWidget {
  final String text;
  const SubheadingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ButtonText extends StatelessWidget {
  final String text;
  const ButtonText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class HomePageNavText extends StatelessWidget {
  final String text;
  final Color colour;
  const HomePageNavText({super.key, required this.text, required this.colour});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: colour,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}

class DropletAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const DropletAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.gantari(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PageTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const PageTopBar({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.gantari(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing! else const SizedBox(width: 0),
      ],
    );
  }
}

class VerticalSpacer extends StatelessWidget {
  final double height;
  const VerticalSpacer({super.key, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class HorizontalSpacer extends StatelessWidget {
  final double width;
  const HorizontalSpacer({super.key, this.width = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
