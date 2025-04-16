import 'package:droplet/pages/onboarding/pages/one.dart';
import 'package:droplet/pages/onboarding/pages/three.dart';
import 'package:droplet/pages/onboarding/pages/two.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class OnboardingStage {
  Future<bool> onLeaveStage();
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  Widget fabIcon = const Icon(Icons.keyboard_arrow_right, color: Colors.white);
  int _currentPage = 0;

  final PageController _pageController = PageController();

  final List<Widget> contents = [
    const OnBoardingStageOne(),
    const OnBoardingStageTwo(),
    const OnBoardingStageThree(),
  ];

  Future<bool> handlePageTransition() async {
    if (contents[_currentPage] is OnboardingStage) {
      final onboardingStage = contents[_currentPage] as OnboardingStage;
      setState(() {
        fabIcon = const CircularProgressIndicator(color: Colors.white);
      });
      final bool canContinue = await onboardingStage.onLeaveStage();
      if (!canContinue) {
        setState(() {
          fabIcon = Icon(
            _currentPage == contents.length - 1
                ? Icons.check
                : Icons.keyboard_arrow_right,
            color: Colors.white,
          );
        });
        return false;
      }
      setState(() {
        fabIcon = const Icon(Icons.keyboard_arrow_right, color: Colors.white);
      });
    }
    if (_currentPage == contents.length - 2) {
      setState(() {
        fabIcon = const Icon(Icons.check, color: Colors.white);
      });
    }
    return true;
  }

  Future<void> goToNextPage() async {
    final bool canContinue = await handlePageTransition();
    if (_currentPage < contents.length - 1 && canContinue) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_currentPage == contents.length - 1 && canContinue) {
      final api = context.read<API>();
      await api.onboardComplete();
      Navigator.pushReplacementNamed(context, '/');
    }
    if (!canContinue) {
      if (_currentPage == contents.length - 1) {
      } else {
        context.showErrorSnackbar(
          "Please complete the required fields",
        );
      }
    }
  }

  Future<void> goToPreviousPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        fabIcon = const Icon(Icons.keyboard_arrow_right, color: Colors.white);
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 1000),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 8,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    return contents[index];
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(contents.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: isActive ? 24 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.inverseSurface
                                      .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "back",
            onPressed: goToPreviousPage,
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            child: Icon(
              Icons.keyboard_arrow_left,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: "forward",
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: goToNextPage,
            child: fabIcon,
          ),
        ],
      ),
    );
  }
}
