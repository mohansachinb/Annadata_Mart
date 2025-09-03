// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import '../siginup_page/database_service.dart' show DatabaseService;
import 'package:login_app/pages/model/user_model.dart';
import 'package:siginup_page/database_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _username = "Loading...";
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Widget> _pages = [
    const Center(child: Text("Home Page", style: TextStyle(fontSize: 22))),
    ProfilePage(), // Profile page with real data
    const Center(child: Text("Settings Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = userData['username'] ?? 'User';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _username = 'Error loading';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text('My App'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 8),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _username,
                        style: const TextStyle(color: Colors.white),
                      ),
              ],
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseService _databaseService;
  late Stream<UserModel> _userStream;

  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _profileImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      _databaseService = DatabaseService(user.uid);
      _userStream = _databaseService.userData;
      _loadUserData();
    }
  }

  void _loadUserData() {
    _userStream.listen(
      (user) {
        setState(() {
          _usernameController.text = user.username;
          _emailController.text = user.email;
          _fullNameController.text = user.fullName ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          _bioController.text = user.bio ?? '';
          _profileImageUrl = user.profileImageUrl;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isSaving = true);
        final String imageUrl = await _databaseService.uploadProfileImage(
          image,
        );
        await _databaseService.updateUserProfile(
          UserModel(
            uid: _auth.currentUser!.uid,
            username: _usernameController.text,
            email: _emailController.text,
            fullName: _fullNameController.text,
            phoneNumber: _phoneController.text,
            bio: _bioController.text,
            profileImageUrl: imageUrl,
          ),
        );
        setState(() {
          _profileImageUrl = imageUrl;
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final user = UserModel(
          uid: _auth.currentUser!.uid,
          username: _usernameController.text,
          email: _emailController.text,
          fullName: _fullNameController.text,
          phoneNumber: _phoneController.text,
          bio: _bioController.text,
          profileImageUrl: _profileImageUrl,
        );

        await _databaseService.updateUserProfile(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 15),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Save Button
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
