import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/widget/image_pick_widget.dart';
import 'package:flutter_locatrip/Auth/widget/password_widget.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _idController = TextEditingController();
  /*TextEditingController _pwController = TextEditingController();
  TextEditingController _pwCheckController = TextEditingController();*/
  TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // 정규식을 통한 유효성 검증을 위한 form key
  String? _emailError;
  String? _passwordError;
  String? _passwordCheckError;
  File? _image;

  void _selectImage(XFile pickedFile) {
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _emailValidCheck(String emailInput) {
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$';
    RegExp regex = RegExp(emailPattern);
    setState(() {
      if (!regex.hasMatch(emailInput)) {
        _emailError = "이메일 형식이 아닙니다.";
      } else {
        _emailError = null;
      }
    });
  }

  void _passwordValidCheck(String passwordInput) {
    setState(() {
      if (passwordInput.length < 6) {
        _passwordError = "비밀번호는 6자 이상이어야 합니다.";
      } else if (passwordInput.length > 20) {
        _passwordError = "비밀번호는 20자를 초과할 수 없습니다.";
      } else {
        const passwordpattern =
            r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{6,20}$';
        RegExp regex = RegExp(passwordpattern);
        if (!regex.hasMatch(passwordInput)) {
          _passwordError = "비밀번호에는 영문, 숫자, 특수문자가 포함되어야 합니다.";
        } else {
          _passwordError = null;
        }
      }
    });
  }

  void _passwordCompareCheck(String passwordCheckInput) {
    setState(() {});
  }

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
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : AssetImage('assets/default_profile_image.png')
                            as ImageProvider,
                  ),
                  ImagePickWidget(selectImage: _selectImage),
                ]),
                SizedBox(
                  height: 39,
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
                                onChanged: _emailValidCheck,
                                controller: _idController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide:
                                            BorderSide(color: pointBlueColor)),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
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
                            SizedBox(
                              width: 16,
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
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      _emailError == null
                          ? SizedBox()
                          : Row(
                              children: [
                                Text(
                                  _emailError!, // dynamic String
                                  style: _emailError!.contains("형식")
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.red)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.green),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                PasswordWidget(),
              ],
            ),
          ),
        ));
  }
}
