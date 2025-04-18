import 'dart:io';

import 'package:droplet/pages/login/login.dart';
import 'package:droplet/pages/main/mainpage.dart';
import 'package:droplet/pages/nonetwork/nonetwork.dart';
import 'package:droplet/pages/onboarding/onboarding.dart';
import 'package:droplet/utils/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _navigateToHome();
  }

  Future<bool> hasNetwork(String knownUrl) async {
    if (kIsWeb) {
      return _hasNetworkWeb(knownUrl);
    } else {
      return _hasNetworkMobile(knownUrl);
    }
  }

  Future<bool> _hasNetworkWeb(String knownUrl) async {
    return true;
  }

  Future<bool> _hasNetworkMobile(String knownUrl) async {
    try {
      final result = await InternetAddress.lookup(knownUrl);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {}
    return false;
  }

  Future<bool> isOnBoarded() async {
    final api = context.read<API>();
    final currentPrefs = await api.account?.getPrefs();
    return currentPrefs?.data["onboarded"] == true;
  }

  _navigateToHome() async {
    if (!await hasNetwork("appwrite.danieldb.uk")) {
      return Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NoNetworkPage()),
      );
    }

    final api = context.read<API>();
    await api.init();
    await api.loadUser();
    final status = api.status;

    if (status == AccountStatus.authenticated) {
      if (!await isOnBoarded()) {
        return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnBoardingPage()),
          (route) => false,
        );
      }
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainPage(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  ScaleTransition(scale: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (r) => false,
      );
    }
  }

  final loadingTextOptions = [
    'just a second...',
    'loading...',
    'please wait...',
    'hang tight...',
    'getting things ready...',
    'just a moment...',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Droplet.',
                style: GoogleFonts.redHatDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                loadingTextOptions[DateTime.now().millisecondsSinceEpoch %
                    loadingTextOptions.length],
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
