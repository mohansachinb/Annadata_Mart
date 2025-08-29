import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/pages/profile/profile_page.dart';
import '../profile/profile_page.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String name;
  const OtpPage({super.key, required this.verificationId, required this.name});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyOtp() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  ProfileFormPage(initialName: widget.name, initialEmail: ""),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Enter the OTP sent to your phone"),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _verifyOtp, child: const Text("Verify")),
          ],
        ),
      ),
    );
  }
}