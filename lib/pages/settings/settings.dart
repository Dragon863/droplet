import 'package:droplet/themes/helpers.dart';
import 'package:droplet/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 500),
            child: ListView(
              physics: ScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PageTopBar(title: "Settings"),
                ),
                ListTile(
                  title: const Text(
                    'Light mode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      themeProvider.themeMode == ThemeMode.light
                          ? const Text('Enabled')
                          : const Text('Disabled'),
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.light,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    onChanged: (value) {
                      themeProvider.setThemeMode(
                        themeProvider.themeMode == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
