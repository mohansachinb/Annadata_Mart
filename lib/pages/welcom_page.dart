import 'package:flutter/material.dart';
import 'package:login_app/pages/login/login_page.dart';

import 'siginup_page/signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              margin: const EdgeInsets.fromLTRB(111, 55, 110.5, 0),
              child: Image.asset(
                "assets/icons/logo.png",
                height: 126.5,
                width: 138.5,
              ),
            ),
          ),

          // Title
          const Text(
            "Welcome to"
            " AM",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              color: Color.fromARGB(249, 22, 22, 151),
            ),
          ),

          const SizedBox(height: 23),

          // Subtitle
          const Text(
            "LET ACCESS ALL WORKS FROM HERE",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 40), // space before buttons
          // ✅ Buttons right after text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 112.5,
                height: 37.5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Login",

                    style: TextStyle(
                      color: Color.fromARGB(237, 21, 21, 218),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 112.5,
                height: 37.5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Signup",
                    style: TextStyle(
                      color: Color.fromARGB(237, 21, 21, 218),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Image.asset("assets/images/image_3.png", height: 365, width: 365),
        ],
      ),
    );
  }
}
