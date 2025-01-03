import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/splash_screen_for_loading.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final AuthModel _authModel = AuthModel();

  void _logout() async {
    String result = await _authModel.logout();
  }

  @override
  void initState() {
    // 로딩동안 splash screen 띄우기
    /*LoadingOverlay.show();
    await fetchData();
    LoadingOverlay.hide();*/
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
              // splashColor: pointBlueColor,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications),
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
          IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        // 색??
                      ),
                      child: Column(
                        children: [
                          // 프로필
                          Container(
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
                              )),
                          // 중간선
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(
                              color: lightGrayColor,
                              thickness: 1,
                            ),
                          ),
                          Container(),
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
