import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/screen/signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/widget/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  bool saveId = false;
  bool autoLogin = false;
  final AuthModel _authModel = AuthModel();

  // 아이디 저장 옵션 상태 저장(로그인 성공시)
  Future<void> savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    await prefs.setBool('saveId', saveId);
    await prefs.setBool('autoLogin', autoLogin);
    if (saveId) {
      await prefs.setString('userId', _idController.text);
    } else {
      await prefs.remove('userId');
    }
    if (autoLogin) {
      _storage.write(key: 'user_id', value: _idController.text);
      _storage.write(key: 'password', value: _pwController.text);
    }
  }

  // 아이디 저장 옵션 상태 불러오기(로그인 스크린 시작시)
  Future<void> getLoginOptions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      saveId = prefs.getBool('saveId') ?? false;
      autoLogin = prefs.getBool('autoLogin') ?? false;
      if (saveId) {
        _idController.text = prefs.getString('userId') ?? '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getLoginOptions();
  }

  void _toggleSaveId() {
    setState(() {
      saveId = !saveId;
    });
  }

  void _toggleAutoLogin() {
    setState(() {
      autoLogin = !autoLogin;
    });
  }

  Widget _loginOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleSaveId,
          child: Row(
            children: [
              Icon(
                saveId ? Icons.check_circle : Icons.radio_button_unchecked,
                color: saveId ? pointBlueColor : grayColor,
              ),
              SizedBox(width: 5),
              Text(
                "아이디 저장",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: blackColor),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: _toggleAutoLogin,
          child: Row(
            children: [
              Icon(
                autoLogin ? Icons.check_circle : Icons.radio_button_unchecked,
                color: autoLogin ? pointBlueColor : grayColor,
              ),
              SizedBox(width: 5),
              Text(
                "자동로그인",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: blackColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _login() async {
    if (_idController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("아이디를 입력해주세요.")));
    } else if (_pwController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("비밀번호를 입력해주세요.")));
    } else {
      Map<String, String> loginData = {
        'userId': _idController.text,
        'password': _pwController.text,
      };

      try {
        String result = await _authModel.login(loginData);
        await savePreference();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));
        Navigator.pushReplacementNamed(context, "/home");
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          String cleanMessage = errorMessage.substring(10).trim();
          if (cleanMessage.startsWith("Error")) {
            cleanMessage = "서버에러! 다시 로그인 해주세요.";
          }
          showCustomDialog(context, cleanMessage);
        }
      }
    }
  }

  void showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // dialog 밖에 눌렀을때 닫힘 방지
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: pointBlueColor,
                        size: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: blackColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pointBlueColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "확인",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 다른데 누르면 키보드 감춤
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 180, 16, 30),
                child: Center(
                  child: Column(
                    children: [
                      Text("Locat에 오신 것을 환영합니다.",
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Locat은 현지인이 추천해주는",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text("여행 계획 서비스 입니다.",
                          style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "아이디",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: blackColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Container(
                              height: 45,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _idController,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: BorderSide(
                                                  color: pointBlueColor)),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: lightGrayColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: pointBlueColor,
                                            ),
                                          ),
                                          hintText: "example@locat.com",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: grayColor,
                                              ),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(8, 0, 8, 0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "비밀번호",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: blackColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Container(
                              height: 45,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _pwController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: BorderSide(
                                                  color: pointBlueColor)),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: lightGrayColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: pointBlueColor,
                                            ),
                                          ),
                                          hintText: "비밀번호 입력",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: grayColor,
                                              ),
                                          contentPadding:
                                              EdgeInsets.fromLTRB(8, 0, 8, 0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      _loginOptions(), // 아이디 저장, 자동로그인 체크버튼
                      SizedBox(
                        height: 16,
                      ),
                      TextButton(
                        onPressed: _login,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "로그인",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size(380, 60),
                          backgroundColor: pointBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextButton(
                        onPressed: _login, // 카카오 로그인 추가
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/kakao_logo.png"),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              "카카오 로그인",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size(380, 60),
                          backgroundColor: kakaoYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                          child: Text.rich(TextSpan(
                        children: [
                          TextSpan(
                              text: "아직 회원이 아니신가요? ",
                              style: Theme.of(context).textTheme.bodySmall),
                          TextSpan(
                              text: "회원가입",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: pointBlueColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SignupScreen()));
                                })
                        ],
                      )))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
