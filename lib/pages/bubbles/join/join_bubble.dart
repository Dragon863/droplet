import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool?> joinBubble(BuildContext context) async {
  final TextEditingController codeController = TextEditingController();

  final String? joinCode = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Join a Bubble",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: codeController,
          onSubmitted: (value) {
            Navigator.of(context).pop(value);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            hintText: "e.g. 12345678",
            labelText: "Invite code",
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(codeController.text);
            },
            child: Text("Join"),
          ),
        ],
      );
    },
  );

  if (joinCode == null || joinCode.isEmpty) {
    return false;
  }
  try {
    final API api = context.read<API>();
    final String response = await api.joinBubbleWithCode(joinCode);
    context.showSuccessSnackbar(response);
    return true;
  } catch (e) {
    context.showErrorSnackbar(e.toString());
    return false;
  }
}
