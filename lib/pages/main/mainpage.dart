import 'package:droplet/pages/home/home.dart';
import 'package:droplet/pages/settings/settings.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;

  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const Text('Activity'),
    const Text('Friends'),
    const SettingsPage(),
  ];

  void _setPage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _assetFor(int index) {
    final bool isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    final bool isActive = _currentPage == index;
    int size = 32;
    final String path =
        'assets/icons/${['home', 'activity', 'friends', 'settings'][index]}${isActive ? '' : '-outline'}.svg';

    return
    // Scale up then down to fix aliasing issues
    Transform.scale(
      filterQuality: FilterQuality.medium,
      scale: 1 / 2,
      child: Transform.scale(
        scale: 2,
        child: SvgPicture.asset(
          path,
          key: ValueKey<String>(path),
          height: size.toDouble(),
          width: size.toDouble(),
          colorFilter:
              isDark
                  ? isActive
                      // Active dark
                      ? const ColorFilter.mode(
                        Color(0xFFE2D4FF),
                        BlendMode.srcIn,
                      )
                      // Inactive dark
                      : const ColorFilter.mode(
                        Color(0xFFA493C6),
                        BlendMode.srcIn,
                      )
                  : isActive
                  // Active light
                  ? ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  )
                  // Inactive light
                  : const ColorFilter.mode(
                    Color.fromARGB(255, 68, 48, 97),
                    BlendMode.srcIn,
                  ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    final bool isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    final bool isActive = _currentPage == index;

    return GestureDetector(
      onTap: () => _setPage(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale:
                  _currentPage == index
                      ? 1.1
                      : 1.0, // Slightly increase size when active
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: _assetFor(index),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: 1.0, //_currentPage == index ? 1.0 : 0.0,
              child: HomePageNavText(
                text: label,
                colour:
                    isActive
                        ? isDark
                            //  Active dark
                            ? const Color(0xFFE2D4FF)
                            // Active light
                            : Theme.of(context).colorScheme.onSurface
                        : isDark
                        // Inactive dark
                        ? const Color(0xFFA493C6)
                        // Inactive light
                        : Color.fromARGB(255, 68, 48, 97),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildNavItem(0, 'Home')),
                Expanded(child: _buildNavItem(1, 'Activity')),
                Expanded(child: _buildNavItem(2, 'Friends')),
                Expanded(child: _buildNavItem(3, 'Settings')),
              ],
            ),
          ),

          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: _pages[_currentPage],
          ),
        ),
      ),
    );
  }
}
