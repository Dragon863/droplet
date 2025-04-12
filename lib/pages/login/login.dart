import 'package:droplet/utils/api.dart';
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

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void checkEmailValidity(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (emailRegex.hasMatch(email)) {
      setState(() {
        _isemailValid = true;
      });
    } else {
      setState(() {
        _isemailValid = false;
      });
    }
  }

  void checkPasswordValidity(String password) {
    if (password.length >= 8) {
      setState(() {
        _isPasswordValid = true;
      });
    } else {
      setState(() {
        _isPasswordValid = false;
      });
    }
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
              decoration: InputDecoration(
                label: const Text('Email'),
                border: const OutlineInputBorder(),
                errorText: _isemailValid ? null : 'Email is invalid',
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorStyle: const TextStyle(color: Colors.red),
                errorMaxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              obscureText: !_isPasswordVisible,
              enableSuggestions: false,
              autocorrect: false,
              enableInteractiveSelection: false,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                label: const Text('Password'),
                border: const OutlineInputBorder(),
                errorText: _isPasswordValid ? null : 'Password is too short',
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
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
          const SizedBox(height: 32),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  checkEmailValidity(_emailController.text);
                  checkPasswordValidity(_passwordController.text);
                  if (!_isemailValid || !_isPasswordValid) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid email or password'),
                      ),
                    );
                    return;
                  }

                  final API api = context.read<API>();
                  api
                      .createEmailSession(
                        email: _emailController.text,
                        password: _passwordController.text,
                      )
                      .then((_) {
                        // Handle successful login here
                        Navigator.pushReplacementNamed(context, '/main');
                      })
                      .catchError((error) {
                        // Handle login error here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $error')),
                        );
                      });

                  setState(() => _isLoading = false);
                },
                child: const Text('Log In'),
              ),
              const SizedBox(width: 8),
              const Text(" • "),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  checkEmailValidity(_emailController.text);
                  checkPasswordValidity(_passwordController.text);
                  if (!_isemailValid || !_isPasswordValid) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid email or password'),
                      ),
                    );
                    return;
                  }

                  final API api = context.read<API>();
                  api
                      .createUser(
                        email: _emailController.text,
                        password: _passwordController.text,
                      )
                      .then((_) {
                        // Handle successful login here
                        Navigator.pushReplacementNamed(context, '/main');
                      })
                      .catchError((error) {
                        // Handle login error here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $error')),
                        );
                      });

                  setState(() => _isLoading = false);
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: Color(0xFF9B51E0)),
            ),
            onPressed: () {},
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
