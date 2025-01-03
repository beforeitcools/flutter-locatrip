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
          title: Text(
            "여행자, 평온한토미님!",
            style: TextStyle(fontSize: 20),
            // 참고용
            // style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: Text("메인"),
    );
  }
}
