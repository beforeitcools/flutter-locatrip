import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/screen/login_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/splash_screen_for_loading.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/cusotom_dialog.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final AuthModel _authModel = AuthModel();
  final MypageModel _mypageModel = MypageModel();
  dynamic? userData;

  void _logout() async {
    try {
      String result = await _authModel.logout();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/start',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("로그아웃 완료")));
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/start',
        (Route<dynamic> route) => false,
      );
    }
  }

  void _loadMypageData() async {
    Map<String, dynamic> result = await _mypageModel.getMyPageData(context);
    setState(() {
      userData = result['user'];
      print(userData);
    });
  }

  @override
  void initState() {
    super.initState();
    // 로딩동안 splash screen 띄우기
    LoadingOverlay.show();
    _loadMypageData();
    LoadingOverlay.hide();
  }

  Widget _buildIconOrImage(dynamic icon) {
    if (icon is String) {
      return Image.asset(
        icon,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
      );
    } else if (icon is IconData) {
      return Icon(icon, size: 24, color: blackColor);
    } else {
      return Icon(Icons.error_outline, size: 24, color: blackColor);
    }
  }

  Widget _materialCreator(dynamic icon, String title /*, String screenName*/) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () {},
          splashColor: Color.fromARGB(50, 43, 192, 228),
          highlightColor: Color.fromARGB(30, 43, 192, 228),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 56,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                _buildIconOrImage(icon),
                SizedBox(
                  width: 16,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Spacer(),
                Icon(Icons.chevron_right),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
              onPressed: () {
                // 알림창으로 이동
              },
              splashRadius: 24,
              splashColor: Color.fromARGB(70, 43, 192, 228),
              highlightColor: Color.fromARGB(50, 43, 192, 228),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_outlined),
                  // 새로운 알림 여부 ?
                  Positioned(
                    right: -1,
                    top: 1,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                  )
                ],
              )),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            splashRadius: 24,
            splashColor: Color.fromARGB(70, 43, 192, 228),
            highlightColor: Color.fromARGB(50, 43, 192, 228),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 116,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: 148,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: lightGrayColor,
                            width: 1.0,
                          )),
                      child: Column(
                        children: [
                          // 프로필
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              splashColor: Color.fromARGB(50, 43, 192, 228),
                              highlightColor: Color.fromARGB(30, 43, 192, 228),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 92,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      // 프로필 이미지
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                                'assets/default_profile_image.png')
                                            as ImageProvider,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      // 닉네임
                                      Text(
                                        "namjoon",
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ), // 너무 길면 처리(...)
                                      SizedBox(
                                        width: 16,
                                      ),
                                      // 베지(있으면)
                                      Icon(
                                        Icons.verified_outlined,
                                        color: pointBlueColor,
                                      ),
                                      Spacer(),
                                      Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 54,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                          color: lightGrayColor,
                                          width: 1.0,
                                        ),
                                      )),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/icon/editor_choice.png",
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Text(
                                          "내 첨삭 채택수",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        SizedBox(
                                          height: 16,
                                          width: 40,
                                          child: VerticalDivider(
                                            color: grayColor,
                                            thickness: 1.0,
                                          ),
                                        ),
                                        Text("101",
                                            style: TextStyle(
                                              color: pointBlueColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            )),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: lightGrayColor,
                            width: 1.0,
                          )),
                      child: _materialCreator(
                          "assets/icon/home_pin.png", "현지인 인증하기"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 226,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: lightGrayColor,
                            width: 1.0,
                          )),
                      child: Column(
                        children: [
                          _materialCreator("assets/icon/trip.png", "내 여행"),
                          _materialCreator(
                              Icons.favorite_border_outlined, "내 저장"),
                          _materialCreator(Icons.article_outlined, "내 포스트"),
                          _materialCreator(
                              "assets/icon/rate_review.png", "내 첨삭"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
