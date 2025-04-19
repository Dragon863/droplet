import 'package:droplet/pages/policy/privacy.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isemailValid = true;
  bool _isPasswordValid = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void checkEmailValidity(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    setState(() {
      _isemailValid = emailRegex.hasMatch(email);
    });
  }

  void checkPasswordValidity(String password) {
    setState(() {
      _isPasswordValid = password.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Image.asset('assets/logo-no-bg.png', height: 180, width: 180),
          Text(
            'Droplet.',
            style: GoogleFonts.redHatDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'small, simple socials',
            style: GoogleFonts.ibmPlexMono(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              controller: _emailController,
              onChanged: checkEmailValidity,
              decoration: InputDecoration(
                label: const Text('Email'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                errorText: _isemailValid ? null : 'Email is invalid',

                errorMaxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              obscureText: !_isPasswordVisible,
              enableSuggestions: false,
              autocorrect: false,
              enableInteractiveSelection: false,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              onChanged: checkPasswordValidity,
              decoration: InputDecoration(
                label: const Text('Password'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                errorText: _isPasswordValid ? null : 'Password is too short',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: togglePasswordVisibility,
                ),
              ),
              controller: _passwordController,
            ),
          ),
          const SizedBox(height: 48),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    checkEmailValidity(_emailController.text);
                    checkPasswordValidity(_passwordController.text);
                    if (!_isemailValid || !_isPasswordValid) {
                      context.showErrorSnackbar('Invalid email or password');
                      return;
                    }
                    setState(() => _isLoading = true);

                    final API api = context.read<API>();
                    api
                        .createEmailSession(
                          email: _emailController.text,
                          password: _passwordController.text,
                        )
                        .then((_) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        })
                        .catchError((error) {
                          if (mounted) {
                            context.showErrorSnackbar('Login failed: $error');
                          }
                        })
                        .whenComplete(() {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        });
                  },
                  child: const Text('Log In'),
                ),
                const SizedBox(width: 8),
                const Text(" • "),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    checkEmailValidity(_emailController.text);
                    checkPasswordValidity(_passwordController.text);
                    if (!_isemailValid || !_isPasswordValid) {
                      context.showErrorSnackbar('Invalid email or password');
                      return;
                    }
                    setState(() => _isLoading = true);

                    final API api = context.read<API>();
                    api
                        .createUser(
                          email: _emailController.text,
                          password: _passwordController.text,
                        )
                        .then((_) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        })
                        .catchError((error) {
                          if (mounted) {
                            context.showErrorSnackbar('Sign up failed: $error');
                          }
                        })
                        .whenComplete(() {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        });
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          const Spacer(),
          InkWell(
            child: Text(
              'View our Privacy Policy',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
