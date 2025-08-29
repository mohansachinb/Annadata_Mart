import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app/pages/home/home_page.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key, required String initialName, required String initialEmail});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String address = '';
  String pincode = '';
  String city = '';
  String state = '';
  String bio = '';
  String qualification = '';
  String topic = '';

  /// Save Profile to Firestore and Navigate
  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": name,
        "address": address,
        "pincode": pincode,
        "city": city,
        "state": state,
        "bio": bio,
        "qualification": qualification,
        "topic": topic,
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );

      // ✅ Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Profile Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Name', 'Enter Your Name', (val) => name = val),
              _buildTextField(
                'Address',
                'Enter Your Address',
                (val) => address = val,
              ),
              _buildTextField(
                'Pincode',
                'Enter Your Area Pincode',
                (val) => pincode = val,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'City',
                      'Your City',
                      (val) => city = val,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'State',
                      'Your State',
                      (val) => state = val,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                'Write Something About Yourself',
                'Enter Your Bio',
                (val) => bio = val,
              ),

              const SizedBox(height: 16),
              const Text('Choose Your Qualifications'),
              _buildDropdown('Qualifications', [
                'High School',
                'Graduate',
                'Post Graduate',
              ], (val) => qualification = val!),

              const SizedBox(height: 16),
              const Text('Choose Your Topics'),
              _buildDropdown('Topics', [
                'Math',
                'Science',
                'English',
              ], (val) => topic = val!),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom TextField builder
  Widget _buildTextField(
    String label,
    String hint,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onChanged,
        validator: (val) =>
            val == null || val.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  /// Custom Dropdown builder
  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: label,
        border: const UnderlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (val) =>
          val == null || val.isEmpty ? 'Please select $label' : null,
    );
  }
}
