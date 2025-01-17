import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/main/model/main_model.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';

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
  final TripModel _tripModel = TripModel();
  final MainModel _mainModel = MainModel();
  final MypageModel _mypageModel = MypageModel();

  bool _isLoading = true;

  int? _inviteId;
  int? _hostId;

  late String _profilePic;
  late String _hostNickName;
  late String _nickName;

  @override
  void initState() {
    super.initState();

    _inviteId = Provider.of<InviteState>(context, listen: false).inviteId;
    _hostId = Provider.of<InviteState>(context, listen: false).hostId;

    // 일정에 참여 중인 유저인지 확인
    if (_inviteId != null && _hostId != null) _isExistTripUser();

    _getUserInfo();
  }

  void _isExistTripUser() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final dynamic stringId = await _storage.read(key: 'userId');
    var userId = int.tryParse(stringId) ?? 0; // 초대받은 사용자

    // 초대받은 사용자와 호스트 비교
    if (userId == _hostId) {
      showExistsModal(context);
      return;
    }

    Map<String, dynamic> data = {"tripId": _inviteId, "userId": userId};

    try {
      bool isExistTripUser =
          await _tripUserModel.isExistTripUser(context, data);

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

  // 호스트 정보 불러오기
  _getHostUserInfo() async {
    try {
      Map<String, dynamic> result =
          await _mainModel.getHostUserInfo(context, _hostId!);

      if (result.isNotEmpty) {
        setState(() {
          _profilePic =
              result["profilePic"] != null ? result["profilePic"] : "null";
          _hostNickName = result["nickname"];
        });
      }
    } catch (e) {
      print('에러메시지?? $e');
    }
  }

  // 초대 모달
  void showInviteModal(BuildContext context, int inviteId) async {
    try {
      Map<String, dynamic> tripInfoMap =
          await _tripModel.selectTrip(inviteId, context);
      print('tripInfoMap $tripInfoMap');
      await _getHostUserInfo();

      if (tripInfoMap.isNotEmpty) {
        if (_profilePic.isNotEmpty && _hostNickName.isNotEmpty) {
          String defaultImageUrl = "assets/default_profile_image.png";
          _profilePic == "null" ? defaultImageUrl : _profilePic;
          String region = tripInfoMap["selectedRegions"][0]["region"];
          int regionLength = tripInfoMap["selectedRegions"].length - 1;
          String elseString = regionLength > 0 ? " 외 $regionLength개 도시" : "";

          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 16),
                    title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Image.asset(
                              _profilePic.toString() ?? defaultImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  defaultImageUrl,
                                  width: 50,
                                  height: 50,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 15),
                          FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Text(
                              '$region$elseString 여행',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            "${tripInfoMap["startDate"]} - ${tripInfoMap["endDate"]}",
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ]),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$_hostNickName님이 여행에 초대했어요.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: grayColor),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "초대를 수락하고 함께 즐거운 여행을 계획해보세요.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: grayColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actionsPadding: EdgeInsets.only(bottom: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      // 닫기 버튼
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: grayColor,
                                  fontWeight: FontWeight.w500),
                        ),
                      ),
                      // 수락하기 버튼
                      TextButton(
                        onPressed: () {
                          // 초대 ID 비우기
                          /*Provider.of<InviteState>(context, listen: false).setInviteId(null);*/
                          _saveTripUser();
                          // 모달 닫기
                          Navigator.pop(context);
                        },
                        child: Text(
                          '초대수락',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: pointBlueColor,
                                  fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ));
        }
      }
    } catch (e) {
      print('에러메시지 $e');
    }
  }

  // 이미 일정에 참여 중 일 때
  void showExistsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(30),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        actionsPadding: EdgeInsets.only(bottom: 10),
        content: Text(
          '이미 참여하고 있는 여행입니다.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<InviteState>(context, listen: false)
                  .setInviteId(null);
              Navigator.pop(context);
            },
            child: Text(
              '확인',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: pointBlueColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 현재 로그인된 사용자 정보
  _getUserInfo() async {
    try {
      Map<String, dynamic> user = await _mypageModel.getMyPageData(context);
      if (user.isNotEmpty) {
        setState(() {
          _nickName = user["user"]["nickname"];
          _isLoading = false;
        });
      }
    } catch (e) {
      _isLoading = false;
      print('에러메시지 $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: AppBar(
          leadingWidth: 0,
          leading: SizedBox.shrink(),
          title: _isLoading
              ? SizedBox.shrink()
              : Text(
                  "여행자, ${_nickName}님!",
                  style: TextStyle(fontSize: 20),
                ),
          actions: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.notifications_outlined)),
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
