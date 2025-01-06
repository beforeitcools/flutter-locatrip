import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/advice_screen.dart';
import 'package:flutter_locatrip/chatting/screen/chatting_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../main/screen/main_screen.dart';
import '../../map/model/app_overlay_controller.dart';
import '../../map/screen/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 탭에 따라 표시할 화면들
  final List<Widget> _pages = [
    MainScreen(),
    MapScreen(),
    AdviceScreen(),
    ChattingScreen(),
    // MypageScreen(),
  ];

  // 탭 선택 시 호출 함수
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
      AppOverlayController.removeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: "홈"),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined), label: "지도"),
            BottomNavigationBarItem(
                icon: Icon(Icons.recommend_outlined), label: "여행첨삭소"),
            BottomNavigationBarItem(
                icon: Icon(Icons.sms_outlined), label: "채팅"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined), label: "마이페이지"),
          ],
        ),
      ),
    );
  }
}
