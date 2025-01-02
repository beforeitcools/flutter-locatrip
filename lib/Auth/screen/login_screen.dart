import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../common/widget/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();

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
                padding: EdgeInsets.fromLTRB(16, 84, 16, 16),
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
                                      // onChanged: _passwordValidCheck,
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
                      TextButton(
                        onPressed: () {
                          // 로그인 요청
                          /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));*/
                        },
                        child: Text(
                          "로그인",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
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
                                  Navigator.pushReplacementNamed(
                                      context, '/signup');
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
