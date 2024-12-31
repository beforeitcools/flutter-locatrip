import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/screen/signup_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 106,
            ),
            Image(
              image: AssetImage('assets/logo_with_image.png'),
            ),
            SizedBox(
              height: 30,
            ),
            Text("현지인이 첨삭해주는 맞춤 여행 가이드",
                style: Theme.of(context).textTheme.bodyMedium),
            Text("지금 내 동네를 인증하고 여행을 계획하세요!",
                style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(
              height: 200,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Text(
                      "시작하기",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: Size(380, 60), // 최소 높이 설정
                      backgroundColor: pointBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 둥근 테두리 설정
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
                          text: "이미 계정이 있나요? ",
                          style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(
                          text: "로그인",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: pointBlueColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigator.pushReplacementNamed(context, '/signup');
                            })
                    ],
                  )))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
