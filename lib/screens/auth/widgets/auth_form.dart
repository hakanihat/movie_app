import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/widgets/hover_animated_button.dart';

class AuthForm extends StatefulWidget {
  final String title;
  final bool isLogin;
  final Future<void> Function({
    required String email,
    required String password,
    String? confirmPassword,
  })
  onSubmit;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onToggleAuthMode;

  const AuthForm({
    super.key,
    required this.title,
    required this.isLogin,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.onToggleAuthMode,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Please fill both Email and Password fields!");
      return;
    }

    if (!widget.isLogin) {
      final confirm = _confirmPasswordController.text.trim();
      if (confirm.isEmpty) {
        _showErrorSnackBar("Please confirm your password!");
        return;
      }
      if (password != confirm) {
        _showErrorSnackBar("Passwords do not match!");
        return;
      }
      final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).+$');
      if (!regex.hasMatch(password)) {
        _showErrorSnackBar(
          "Password must contain at least one uppercase letter and one number!",
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isLogin) {
        await widget.onSubmit(email: email, password: password);
      } else {
        await widget.onSubmit(
          email: email,
          password: password,
          confirmPassword: _confirmPasswordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? "Authentication error!");
    } catch (err) {
      _showErrorSnackBar("Something went wrong. Please try again!");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar("Please enter your email to reset password.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? "Error sending password reset email.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (!widget.isLogin) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
            const SizedBox(height: 20),
            animatedButton(
              button: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(widget.isLogin ? 'LOGIN' : 'CREATE ACCOUNT'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onToggleAuthMode,
              child: Text(
                widget.isLogin
                    ? 'No account? Register here'
                    : 'Already have an account? Login here',
              ),
            ),
            if (widget.isLogin)
              TextButton(
                onPressed: _forgotPassword,
                child: const Text("Forgot Password?"),
              ),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('OR'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            animatedButton(
              button: ElevatedButton.icon(
                icon: Image.asset('assets/images/google_logo.png', height: 20),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: widget.onGoogleSignIn,
              ),
            ),
          ],
        );
  }
}
