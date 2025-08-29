import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavExample(),
    );
  }
}

class BottomNavExample extends StatefulWidget {
  const BottomNavExample({super.key});

  @override
  State<BottomNavExample> createState() => _BottomNavExampleState();
}

class _BottomNavExampleState extends State<BottomNavExample> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text("🏠 Home Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("📚 Store Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("🔍 Find Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("👤 Profile Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.deepPurple, // 🔹 Background = deepPurple
        color: Colors.black, // 🔹 Inactive icons/text = black
        activeColor: Colors.white, // 🔹 Active icons/text = white
        elevation: 5,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.book, title: 'Store'),
          TabItem(icon: Icons.search, title: 'Find'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: 0,
        onTap: (int i) {
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }
}
