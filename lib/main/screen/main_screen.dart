import 'package:flutter/material.dart';
import 'package:flutter_locatrip/checklist/screen/checklist_screen.dart';

import '../../trip/screen/trip_screen.dart';

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
            TextButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChecklistScreen(),
                  ),
                );
              },
              child: Text(
                '체크리스트',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Text("메인"),
      floatingActionButton: Container(
        width: 68,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripScreen(),
                  fullscreenDialog: true,
                ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
              ),
              Text(
                "일정생성",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
