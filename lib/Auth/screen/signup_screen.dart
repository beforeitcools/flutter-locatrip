import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import '../widget/image_pick_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  TextEditingController _pwCheckController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();

  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("회원가입", style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 16, 0),
          child: Center(
            child: Column(
              children: [
                Stack(children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: image != null
                        ? FileImage(image!)
                        : AssetImage('assets/default_profile_image.png')
                            as ImageProvider,
                  ),
                  ImagePickWidget(image: image),
                ]),
                SizedBox(
                  height: 39,
                ),
                Container(
                  child: Stack(
                    children: [
                      Text(
                        "아이디",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Container(
                        // padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _idController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "example@locat.com",
                                    helperText: "사용 가능한 아이디 입니다."), // 스타일??
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // 중복 체크
                              },
                              child: Text(
                                "중복확인",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: blackColor),
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: Size(88, 45), // 최소 높이 설정
                                backgroundColor: subPointColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6), // 둥근 테두리 설정
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
