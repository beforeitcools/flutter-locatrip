import 'package:flutter/material.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox.shrink(),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close))
        ],
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text("타이틀"),
              Row(
                children: [Text("여행친구"), Text("0")],
              ),
              Text("함께 여행갈 친구나 가족을 초대해보세요."),
              Text("여행 일정을 함께 계획할 수 있습니다. (최대 15명)"),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Image.asset("assets/kakao-logo.png"),
                          SizedBox(
                            width: 5,
                          ),
                          Text("카카오톡 초대")
                        ],
                      )),
                  TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(Icons.link),
                          SizedBox(
                            width: 5,
                          ),
                          Text("초대 링크 복사")
                        ],
                      ))
                ],
              )
            ],
          )),
    );
  }
}
