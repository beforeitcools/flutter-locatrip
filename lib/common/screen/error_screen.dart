import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/logo_with_image.pnf'),
            ),
            Text("에러 발생"),
            // 돌아가기 버튼 (어디로?? context 로 이전으로?? home 으로??)
          ],
        ),
      ),
    );
  }
}
