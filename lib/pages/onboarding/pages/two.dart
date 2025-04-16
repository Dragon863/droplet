import 'package:appwrite/models.dart' as models;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:droplet/pages/onboarding/onboarding.dart';
import 'package:droplet/themes/theme_provider.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnBoardingStageTwo extends StatefulWidget implements OnboardingStage {
  const OnBoardingStageTwo({super.key});

  @override
  State<OnBoardingStageTwo> createState() => _OnBoardingStageTwoState();

  static final GlobalKey<_OnBoardingStageTwoState> _stateKey = GlobalKey();

  @override
  Key? get key => _stateKey;

  @override
  Future<bool> onLeaveStage() async {
    final state = _stateKey.currentState;
    if (state != null) {
      final name = state.controller.text;
      if (name != "") {
        await state.saveName(name);
        return true;
      } else {
        return false;
      }
    }
    return true;
  }
}

class _OnBoardingStageTwoState extends State<OnBoardingStageTwo> {
  final TextEditingController controller = TextEditingController();

  Future<void> fetchPrefs() async {
    final API api = context.read<API>();
    final models.User? latestUserModel = await api.account?.get();
    final String displayName = latestUserModel!.name;

    setState(() {
      if (displayName.isNotEmpty) {
        controller.text = displayName;
      }
    });
  }

  Future<void> saveName(String name) async {
    final api = context.read<API>();
    bool fail = false;
    if (api.account == null) {
      fail = true;
    }

    try {
      await api.account!.updateName(name: name);
      fail = false;
    } catch (e) {
      fail = true;
    }
    if (fail) {
      context.showErrorSnackbar("Couldn't save name, please try again later");
    }
  }

  @override
  void initState() {
    fetchPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Display Name",
            style: GoogleFonts.gantari(
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            autofillHints: const [AutofillHints.name],
            controller: controller,
            decoration: InputDecoration(
              hintText: "Display Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "(We'll use this to identify you to your friends. We recommend using your first and last name)",
          ),
          const SizedBox(height: 16),
          Text(
            "Appearance",
            style: GoogleFonts.gantari(
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          ListTile(
            title: const Text('Theme mode'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton2<ThemeMode>(
                value: themeProvider.themeMode,
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                menuItemStyleData: MenuItemStyleData(height: 35),
                buttonStyleData: ButtonStyleData(
                  padding: const EdgeInsets.only(left: 16),
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text("Light"),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text("System"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
