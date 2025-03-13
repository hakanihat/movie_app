import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/screens/auth/widgets/auth_form.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/widgets/gradient_card.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> onSubmit({
    required String email,
    required String password,
    String? confirmPassword,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please, fill the fields for email and password."),
        ),
      );
      return;
    }

    if (!_isLogin) {
      if (confirmPassword == null || confirmPassword.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please confirm your password.")),
        );
        return;
      }

      if (password.trim() != confirmPassword.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
        return;
      }

      final RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).+$');
      if (!passwordRegex.hasMatch(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Password must contain at least one uppercase letter and one number!",
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(email.trim(), password.trim());
      } else {
        await _authService.signUp(email.trim(), password.trim());
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign in aborted')));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google Sign-In error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Sign In' : 'Sign Up';

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height / 2,
                    ),
                    child: Center(
                      child: GradientCard(
                        child: Container(
                          width: 350,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: AuthForm(
                            title: title,
                            isLogin: _isLogin,
                            onSubmit: onSubmit,
                            onGoogleSignIn: onGoogleSignIn,
                            onToggleAuthMode: toggleAuthMode,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
