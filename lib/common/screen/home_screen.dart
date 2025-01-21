import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/post_list_screen.dart';
import 'package:flutter_locatrip/chatting/screen/chatting_screen.dart';
import 'package:flutter_locatrip/mypage/screen/mypage_screen.dart';

import '../../advice/screen/advice_post_screen.dart';
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
  late List<Widget> _pages;
  String _submittedValue = "";

  @override
  void initState() {
    super.initState();

    // 탭에 따라 표시할 화면들
    _pages = [
      MainScreen(onTapped: _onTappedMap),
      MapScreen(region: _submittedValue),
      // PostListScreen(),
      AdvicePostScreen(),
      ChattingScreen(),
      MypageScreen(),
    ];
  }

  // 탭 선택 시 호출 함수
  void _onTapped(int index) {
    setState(() {
      AppOverlayController.removeOverlay();
      _submittedValue = "";
      _pages[1] = MapScreen(region: _submittedValue);
      _selectedIndex = index;
    });
  }

  // 메인에서 맵 이동
  void _onTappedMap(int index, String value) {
    setState(() {
      AppOverlayController.removeOverlay();
      _submittedValue = value;
      _selectedIndex = index;

      _pages[1] = MapScreen(region: "$_submittedValue 추천 여행지");
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
