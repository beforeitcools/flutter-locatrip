import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: AppBar(
          title: Image.asset("assets/logo.png"),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: Text("메인"),
    );
  }
}
