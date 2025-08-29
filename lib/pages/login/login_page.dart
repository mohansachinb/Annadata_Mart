import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Email validation
  void _validateEmail(String value) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      if (value.isEmpty) {
        _emailError = "Email cannot be empty";
      } else if (!regex.hasMatch(value)) {
        _emailError = "Enter a valid email address";
      } else {
        _emailError = null;
      }
    });
  }

  // ✅ Password validation
  void _validatePassword(String value) {
    final regex = RegExp(
      r'^(?=.*[!@#\$%\^&\*])(?=.*\d)[A-Za-z\d!@#\$%\^&\*]{8,16}$',
    );
    setState(() {
      if (value.isEmpty) {
        _passwordError = "Password cannot be empty";
      } else if (!regex.hasMatch(value)) {
        _passwordError =
            "Password must be 8-16 chars,\ninclude a number & a symbol";
      } else {
        _passwordError = null;
      }
    });
  }

  // ✅ Firebase login
  Future<void> _login() async {
    if (_emailError != null || _passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fix errors before login ❌")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful ✅")));

      // TODO: Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else {
        message = "Login failed: ${e.message}";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 38),

            // ✅ Logo
            Center(
              child: Image.asset(
                "assets/icons/logo.png",
                height: 138.5,
                width: 126.5,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Welcome to AM",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                color: Color.fromARGB(249, 22, 22, 151),
              ),
            ),

            const SizedBox(height: 20),

            Image.asset("assets/icons/google_1.png", width: 40, height: 40),

            const SizedBox(height: 25),

            // ✅ Email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: _validateEmail,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _emailError,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Password
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                maxLength: 16,
                onChanged: _validatePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _passwordError,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Login Button
            SizedBox(
              width: 150,
              height: 45,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.blue)
                    : const Text(
                        "Login",
                        style: TextStyle(
                          color: Color.fromARGB(237, 21, 21, 218),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),

            Image.asset("assets/images/image_1.png", height: 246, width: 370),
          ],
        ),
      ),
    );
  }
}
