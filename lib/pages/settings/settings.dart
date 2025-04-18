import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:droplet/pages/password_reset/password_reset_page.dart';
import 'package:droplet/pages/policy/privacy.dart';
import 'package:droplet/pages/settings/crop_pfp.dart';
import 'package:droplet/themes/helpers.dart';
import 'package:droplet/themes/theme_provider.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/config.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentName = "loading...";
  TextEditingController namePopupController = TextEditingController();
  ImageProvider<Object>? bgImg;

  Future<void> loadName() async {
    final api = context.read<API>();
    final name =
        await api.getName(api.user!.$id, changeForYou: false) ?? "No name set";
    setState(() {
      namePopupController.text = name;
      currentName = name;
    });
  }

  Future<void> loadAvatar() async {
    final api = context.read<API>();
    try {
      final avatarUrl = await api.getPfpUrl(api.user?.$id ?? "0");
      setState(() {
        bgImg = NetworkImage(avatarUrl ?? "");
      });
    } catch (e) {
      print(e);
      setState(() {
        bgImg = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadName();
      loadAvatar();
    });
  }

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
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiaryContainer,
                                      radius: 38,
                                      foregroundImage: bgImg,
                                      child: Text(
                                        currentName[0],
                                        style: GoogleFonts.rubik(
                                          fontSize: 32,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 50, top: 40),
                                    child: Transform.scale(
                                      scale: 0.7,
                                      child: IconButton.filled(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          await photoAction();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      currentName,
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 20,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onTertiaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final String?
                                      namePopup = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Edit name"),
                                            content: TextField(
                                              autofocus: true,
                                              autocorrect: false,
                                              autofillHints: [
                                                AutofillHints.name,
                                              ],
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              controller: namePopupController,
                                              decoration: const InputDecoration(
                                                hintText: "Enter your name",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                autofocus: true,
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                    namePopupController.text,
                                                  );
                                                },
                                                child: const Text("Save"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (namePopup != null) {
                                        setState(
                                          () => currentName = "updating...",
                                        );
                                        final api = context.read<API>();
                                        try {
                                          await api.setName(namePopup);
                                          setState(() {
                                            currentName = namePopup;
                                          });
                                          namePopupController.text =
                                              currentName;
                                        } catch (e) {
                                          context.showErrorSnackbar(
                                            "Failed to update name",
                                          );
                                          final serverCurrentName =
                                              api.user?.name ?? "No name set";
                                          setState(() {
                                            currentName = serverCurrentName;
                                          });
                                        }
                                      }
                                    },
                                    child: const Text("Edit name"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.lightbulb_outline),
                  title: const Text(
                    'Theme mode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton2<ThemeMode>(
                      value: themeProvider.themeMode,
                      alignment: AlignmentDirectional.center,
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: 80,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      menuItemStyleData: MenuItemStyleData(height: 35),
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.only(right: 6, left: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text("Light"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text("Dark"),
                        ),
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
                ListTile(
                  leading: Icon(Icons.schedule),
                  title: const Text(
                    'Notification time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final TextEditingController hourController =
                          TextEditingController();
                      final int? hour = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              "Set Notification Time",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: TextField(
                              controller: hourController,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Enter hour (0-23)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  int.parse(value);
                                  if (int.parse(value) < 0 ||
                                      int.parse(value) > 23) {
                                    context.showErrorSnackbar(
                                      "Please enter a valid hour",
                                    );
                                  }
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                },
                                child: const Text("Cancel"),
                              ),
                              FilledButton(
                                onPressed: () {
                                  if (hourController.text.isEmpty ||
                                      int.parse(hourController.text) < 0 ||
                                      int.parse(hourController.text) > 23 ||
                                      int.tryParse(hourController.text) ==
                                          null) {
                                    context.showErrorSnackbar(
                                      "Please enter a valid hour",
                                    );
                                    return;
                                  }
                                  Navigator.of(
                                    context,
                                  ).pop(int.parse(hourController.text));
                                },
                                child: const Text("Set"),
                              ),
                            ],
                          );
                        },
                      );
                      if (hour != null) {
                        final api = context.read<API>();
                        try {
                          await api.setNotifHour(hour);
                          context.showSuccessSnackbar(
                            "Notification time set to $hour:00",
                          );
                        } catch (e) {
                          print(e);
                          context.showErrorSnackbar(
                            "Failed to set notification time: $e",
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    child: Text(
                      "Set",
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.balance),
                  title: const Text(
                    'Licenses',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => LicensePage(
                              applicationName: "",
                              applicationIcon: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/logo-no-bg.png',
                                    height: 180,
                                    width: 180,
                                  ),
                                  Text(
                                    'Droplet.',
                                    style: GoogleFonts.redHatDisplay(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'small, simple socials',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.password),
                  title: const Text(
                    'Reset Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PasswordResetPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Divider(),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final API api = context.read<API>();
                    final bool? result = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Log Out"),
                          content: const Text(
                            "Are you sure you want to log out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text("Cancel"),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text("Log Out"),
                            ),
                          ],
                        );
                      },
                    );
                    if (result == true) {
                      await api.signOut();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil("/", (route) => false);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.close, color: Colors.red),
                  title: const Text(
                    'Close Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    final bool? confirmed = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Close Account"),
                          content: const Text(
                            "Are you sure you want to close your account? This action is IRRIVERSIBLE and will delete all your data!",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text("Cancel"),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text("Close Account"),
                            ),
                          ],
                        );
                      },
                    );
                    final API api = context.read<API>();
                    if (confirmed == true) {
                      try {
                        await api.closeAccount();
                        context.showSuccessSnackbar(
                          "Account closed successfully",
                        );
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil("/", (route) => false);
                      } catch (e) {
                        context.showErrorSnackbar("Failed to close account");
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> getCurrentPfpFileId() async {
    final api = context.read<API>();
    final Preferences prefs = api.user!.prefs;
    String? toReturn;

    prefs.data.forEach((key, value) {
      if (key == "pfp") {
        toReturn = value;
      }
    });

    return toReturn;
  }

  Future<void> photoAction() async {
    final source = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Select Image Source",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text("Use Camera"),
                leading: Icon(Icons.camera_alt_outlined),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              ListTile(
                title: const Text("Use Gallery"),
                leading: Icon(Icons.photo_outlined),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              ListTile(
                title: const Text("Delete Current"),
                leading: Icon(Icons.delete_outline),
                onTap: () {
                  Navigator.of(context).pop(-1);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    if (source == -1) {
      await deleteAction();
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );

    if (file == null) {
      return;
    }

    final Uint8List bytes = await file.readAsBytes();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PopupCropPage(imageBytes: bytes)),
    );
    if (result.runtimeType == CropSuccess) {
      final Uint8List croppedBytes = (result as CropSuccess).croppedImage;
      final InputFile profilePicture = InputFile.fromBytes(
        bytes: croppedBytes,
        filename: file.name,
      );

      await updateProfilePic(profilePicture);
      final api = context.read<API>();
      final pfpUrl = await api.getPfpUrl(api.user?.$id ?? "0");

      setState(() {
        bgImg = NetworkImage(pfpUrl ?? "");
      });
    } else if (result.runtimeType == CropFailure) {
      context.showErrorSnackbar("Error cropping image");
      return;
    } else if (result == null) {
      context.showInfoSnackbar("Cancelled");
      return;
    }
  }

  Future<void> updateProfilePic(InputFile profilePicture) async {
    final api = context.read<API>();

    final Storage storage = Storage(api.client);

    try {
      final String? fileId = await getCurrentPfpFileId();
      if (fileId != null) {
        await storage.deleteFile(bucketId: "profiles", fileId: fileId);
      }
    } catch (e) {
      // File does not exist, do nothing
    }

    final newPfpFile = await storage.createFile(
      bucketId: "profiles",
      fileId: "unique()",
      file: profilePicture,
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.user(api.currentUser.$id)),
        Permission.delete(Role.user(api.currentUser.$id)),
      ],
    );
    final String newPfpFileId = newPfpFile.$id;
    final Preferences prefs = api.user!.prefs;
    prefs.data["pfp"] = newPfpFileId;

    await api.account!.updatePrefs(prefs: prefs.data);
    await api.pfpUpdated(
      "https://appwrite.danieldb.uk/v1/storage/buckets"
      "/${DropletConfig.profileBucketId}/files/$newPfpFileId/"
      "view?project=${DropletConfig.appwriteProjectId}",
    );
  }

  Future<void> deleteAction() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Profile Picture"),
          content: const Text(
            "Are you sure you want to delete your profile picture?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final api = context.read<API>();
      final Storage storage = Storage(api.client);

      try {
        final String? fileId = await getCurrentPfpFileId();
        if (fileId != null) {
          await storage.deleteFile(bucketId: "profiles", fileId: fileId);
        }

        await api.pfpUpdated("none");
        final prefs = api.user!.prefs;
        prefs.data["pfp"] = "";
        await api.account!.updatePrefs(prefs: prefs.data);
      } catch (e) {
        context.showErrorSnackbar("Error deleting profile picture");
      }

      setState(() {
        bgImg = null;
      });
    }
  }
}
