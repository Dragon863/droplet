import 'package:droplet/themes/helpers.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PageTopBar(
            title: "Reset Password",
            trailing: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  labelText: 'Old Password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController1,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  labelText: 'New Password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController2,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  labelText: 'Confirm Password',
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () async {
                  if (_passwordController1.text.isEmpty ||
                      _passwordController2.text.isEmpty) {
                    context.showErrorSnackbar('Please fill in all fields!');
                    return;
                  }
                  if (_passwordController1.text.length < 8) {
                    context.showErrorSnackbar(
                      'Password must be at least 8 characters long!',
                    );
                    return;
                  }
                  if (_passwordController1.text == _passwordController2.text) {
                    final api = context.read<API>();
                    try {
                      await api.account!.updatePassword(
                        password: _passwordController1.text,
                        oldPassword: _oldPasswordController.text,
                      );

                      context.showSuccessSnackbar('Password updated!');
                      Navigator.pop(context);
                    } catch (e) {
                      context.showErrorSnackbar(e.toString());
                      return;
                    }
                  } else {
                    context.showErrorSnackbar('Passwords don\'t match!');
                  }
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
