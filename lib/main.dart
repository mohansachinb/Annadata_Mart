import 'package:flutter/material.dart';
import 'pages/home/home_page.dart';
import 'pages/welcom_page.dart'; //  make sure file name is correct (welcom_page.dart or welcome_page.dart)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login App',
      theme: ThemeData(
        fontFamily: "EncodeSansExpanded",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomePage(), // ✅ add const if WelcomePage is const
    );
  }
}
