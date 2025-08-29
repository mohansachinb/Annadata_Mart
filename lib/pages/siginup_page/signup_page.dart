import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_app/pages/profile/profile_page.dart';
import 'package:login_app/pages/login/login_page.dart';

import '../login/login_page.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _agreeTerms = false;
  bool _loading = false;
  bool _isEmailSignup = true; // ✅ default: Email signup
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Password Validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Enter password";
    if (value.length < 8) return "Password must be at least 8 characters";
    if (value.length > 16) return "Password cannot exceed 16 characters";
    return null;
  }

  // ✅ Firebase Email Signup
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to Terms and Conditions")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup Successful 🎉")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileFormPage(
            initialName: _nameController.text.trim(),
            initialEmail: _emailController.text.trim(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = "Email already registered.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      } else if (e.code == 'weak-password') {
        message = "Password too weak.";
      } else {
        message = "Signup failed: ${e.message}";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ✅ Google Sign-In
  Future<void> _googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileFormPage(
            initialName: googleUser.displayName ?? '',
            initialEmail: googleUser.email,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    }
  }

  // ✅ Facebook Sign-In
  Future<void> _facebookSignIn() async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        final userCred = await _auth.signInWithCredential(credential);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileFormPage(
              initialName: userCred.user?.displayName ?? '',
              initialEmail: userCred.user?.email ?? '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facebook Sign-In cancelled")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Facebook Sign-In failed: $e")));
    }
  }

  Future<void> _signupWithEmail() async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Verification email bhejo
      await userCred.user?.sendEmailVerification();

      // ✅ Show dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Verify your Email"),
          content: const Text(
            "We have sent a verification link to your email. Please verify to continue.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await userCred.user?.reload();
                if (_auth.currentUser!.emailVerified) {
                  // Close dialog
                  Navigator.pop(context);

                  // Navigate to profile page only if verified
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileFormPage(
                        initialName: _nameController.text.trim(),
                        initialEmail: _emailController.text.trim(),
                      ),
                    ),
                  );
                } else {
                  // ❌ Email not verified -> delete account
                  await userCred.user?.delete();

                  // Close dialog but do not navigate
                  Navigator.pop(context);

                  // Show a message that email is not verified
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Your email is not verified yet."),
                    ),
                  );
                }
              },
              child: const Text("Continue"),
            ),
            TextButton(
              onPressed: () async {
                await userCred.user?.sendEmailVerification();

                // Show a message that verification email is sent again
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Verification email sent again"),
                  ),
                );
              },
              child: const Text("Resend"),
            ),
            TextButton(
              onPressed: () {
                _openEmailApp(); // ✅ Gmail/Outlook open
              },
              child: const Text("Open Email"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.message}")));
    }
  }

  Future<void> _openEmailApp() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '', // Empty, just to open default mail app
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not open email app';
    }
  }

  Future<void> _signupWithPhone() async {
    await _auth.verifyPhoneNumber(
      phoneNumber:
          "+91${_mobileController.text.trim()}", // 👈 apna country code lagao
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileFormPage(
              initialName: _nameController.text.trim(),
              initialEmail: "",
            ),
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              verificationId: verificationId,
              name: _nameController.text.trim(),
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset("assets/icons/logo.png", height: 126.5, width: 138.5),
              const SizedBox(height: 8),
              const Text(
                "Welcome to AchryaX",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(249, 22, 22, 151),
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Name
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null,
                ),
              ),

              // ✅ Email OR Mobile
              if (_isEmailSignup)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Enter your email";
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter your mobile number" : null,
                  ),
                ),

              // ✅ Switch between Email & Mobile
              Padding(
                padding: const EdgeInsets.only(
                  right: 30,
                  top: 2,
                  bottom: 2,
                ), // 👈 kam margin
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 👈 Right align
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEmailSignup = !_isEmailSignup;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // 👈 andar ka padding bhi kam
                        minimumSize: const Size(
                          0,
                          0,
                        ), // 👈 button ka default size hata do
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // 👈 shrink karega
                      ),
                      child: Text(
                        _isEmailSignup
                            ? "Use Mobile instead"
                            : "Use Email instead",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Password fields
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validatePassword,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Re-enter Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Re-enter password";
                    if (value != _passwordController.text)
                      return "Passwords do not match";
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 0),

              // Terms Checkbox
              // ✅ Terms Checkbox
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 2, // 👈 top & bottom margin kam
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreeTerms,
                      onChanged: (value) =>
                          setState(() => _agreeTerms = value!),
                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // 👈 extra space hatao
                      visualDensity:
                          VisualDensity.compact, // 👈 checkbox bhi compact hoga
                    ),
                    const Expanded(
                      child: Text(
                        "I agree to the Terms and Conditions",
                        style: TextStyle(
                          fontSize: 13,
                        ), // 👈 text bhi thoda chhota kar sakte ho
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0),

              // Sign Up Button
              // Sign Up Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          if (_isEmailSignup) {
                            _signupWithEmail(); // ✅ Email flow with verification popup
                          } else {
                            _signupWithPhone(); // ✅ Mobile flow with OTP
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 0),

              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or Sign up with"),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
              ),

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.red,
                      size: 20,
                    ),
                    label: const Text(
                      "Google",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: _googleSignIn,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.blue,
                      size: 20,
                    ),
                    label: const Text(
                      "Facebook",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: _facebookSignIn,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
