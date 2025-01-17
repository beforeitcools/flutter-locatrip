import 'package:flutter/material.dart';
import 'package:flutter_locatrip/trip/model/trip_user_model.dart';
import 'package:flutter_locatrip/trip/screen/first_trip_screen.dart';
import 'package:flutter_locatrip/checklist/screen/checklist_screen.dart';
import 'package:flutter_locatrip/expense/screen/expense_screen.dart';
import 'package:flutter_locatrip/trip/screen/trip_view_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../trip/model/invite_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TripUserModel _tripUserModel = TripUserModel();

  int? _inviteId;
  int? _hostId;

  @override
  void initState() {
    super.initState();

    _inviteId = Provider.of<InviteState>(context, listen: false).inviteId;
    _hostId = Provider.of<InviteState>(context, listen: false).hostId;

    // 일정에 참여중인 유저인지 확인
    if (_inviteId != null && _hostId != null) _isExistTripUser();
  }

  void _isExistTripUser() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final dynamic stringId = await _storage.read(key: 'userId');
    var userId = int.tryParse(stringId) ?? 0; //초대받은 사용자

    // 초대받은 사용자와 호스트 비교
    if (userId == _hostId) {
      showExistsModal(context);
      return;
    }

    Map<String, dynamic> data = {"tripId": _inviteId, "userId": userId};

    try {
      bool isExistTripUser =
          await _tripUserModel.isExistTripUser(context, data);
      print('불러왔어! $isExistTripUser');

      if (isExistTripUser) {
        showExistsModal(context);
      } else {
        showInviteModal(context, _inviteId!);
      }
    } catch (e) {
      print('에러메시지 $e');
    }
  }

  // 수락하면 트립유저에 저장
  void _saveTripUser() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final dynamic stringId = await _storage.read(key: 'userId');
    int userId = int.tryParse(stringId) ?? 0;

    Map<String, dynamic> data = {"tripId": _inviteId, "userId": userId};
    try {
      Map<String, dynamic> saveResult =
          await _tripUserModel.saveTripUser(context, data);
      print('saveResult ${saveResult}');
      if (saveResult.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TripViewScreen(tripId: saveResult["tripId"])));
      }
    } catch (e) {
      print('에러메시지 $e');
    }
  }

  void showInviteModal(BuildContext context, int inviteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('초대받은 여행'),
        content: Text('초대받은 여행: $inviteId'),
        actions: [
          // 수락하기 버튼
          TextButton(
            onPressed: () {
              // 초대ID 비우기
              /*Provider.of<InviteState>(context, listen: false)
                  .setInviteId(null);*/
              _saveTripUser();
              // 모달 닫기
              Navigator.pop(context);
            },
            child: Text('수락하기'),
          ),
          // 닫기 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }

  void showExistsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이미 참여중임 !'),
        content: Text('gg'),
        actions: [
          // 닫기 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 초대 됐는지 확인
    // String? inviteId = Provider.of<InviteState>(context).inviteId;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: AppBar(
          title: Text(
            "여행자, 평온한 토미님!",
            style: TextStyle(fontSize: 20),
            // 참고용
            // style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChecklistScreen(tripId:1, userId:1),
                  ),
                );
              },
              child: Text(
                '체크리스트',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseScreen(tripId: 1),
                    ),
                  );
                },
                child: Text(
                  '가계부',
                  style: TextStyle(color: Colors.black),
                ))
          ],
        ),
      ),
      body: Column(
        children: [
          Text("메인"),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TripViewScreen(tripId: 1)));
              },
              child: Text("일정 불러오는지 테스트")),
          // if (_inviteId != null) SizedBox.shrink(),
        ],
      ),
      floatingActionButton: Container(
        width: 68,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripScreen(),
                  // fullscreenDialog: true,
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
