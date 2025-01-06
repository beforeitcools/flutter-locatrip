import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/widget/error_text_widget.dart';
import 'package:flutter_locatrip/Auth/widget/image_pick_widget.dart';
import 'package:flutter_locatrip/Auth/widget/nickname_widget.dart';
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
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  TextEditingController _pwCheckController = TextEditingController();
  final AuthModel _authModel = AuthModel();
  String? _emailError;
  String? _passwordError;
  String? _passwordCheckError;
  String? _passwordInputForCheck; // pw와 pwCheck 비교를 위한 변수
  String? _nicknameError;
  bool _emailCheck = false;
  bool _passwordCheck = false;
  bool _passwordCompareCheck = false;
  bool _nicknameCheck = false;
  File? _image;

  void _selectImage(XFile pickedFile) {
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _signup() async {
    if (_emailCheck == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("유효한 아이디가 아닙니다.")));
    } else if (_passwordCheck == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("유효한 비밀번호가 아닙니다.")));
    } else if (_passwordCompareCheck == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("비밀번호와 비밀번호 확인이 일치 하지 않습니다.")));
    } else if (_nicknameCheck == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("유효한 닉네임이 아닙니다.")));
    } else {
      Map<String, String> signupData = {
        'userId': _idController.text,
        'password': _pwController.text,
        'nickname': _nicknameController.text
      };

      try {
        String result = await _authModel.signup(signupData, _image);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, "/login"); // 성공시 로그인 screen
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error : $e')));
      }
    }
  }

  void _emailAlreadyExistsCheck() async {
    if (_idController.text.isEmpty) {
      setState(() {
        _emailError = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("이메일 형식에 맞아야 중복 확인 가능합니다.")));
    } else if (_emailError != null && _emailError!.contains("형식")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("이메일 형식에 맞아야 중복 확인 가능합니다.")));
    } else {
      String result = await _authModel.checkUserId(_idController.text);
      setState(() {
        if (result.contains("사용 가능한")) {
          _emailCheck = true;
        }
        _emailError = result;
      });
    }
  }

  void _emailValidCheck(String emailInput) {
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$';
    RegExp regex = RegExp(emailPattern);
    setState(() {
      _emailCheck = false;
      if (!regex.hasMatch(emailInput)) {
        _emailError = "이메일 형식이 아닙니다.";
      } else {
        _emailError = null;
      }
    });
  }

  void _nicknameValidCheckSetState(String nicknameInput) {
    const nicknamePattern = r'^[가-힣A-Za-z0-9]{1,20}$';
    RegExp regex = RegExp(nicknamePattern);
    setState(() {
      _nicknameCheck = false;
      if (!regex.hasMatch(nicknameInput)) {
        _nicknameError = "한글 1~10자, 영문 2~20자 이내, 특수문자 불가";
      } else {
        _nicknameError = null;
      }
    });
  }

  void _nicknameAlreadyExistsCheckSetState() async {
    if (_nicknameController.text.isEmpty) {
      setState(() {
        _nicknameError = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("닉네임 형식에 맞아야 중복 확인 가능합니다.")));
    } else if (_nicknameError != null && _nicknameError!.contains("형식")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("닉네임 형식에 맞아야 중복 확인 가능합니다.")));
    } else {
      String result = await _authModel.checkNickname(_nicknameController.text);
      setState(() {
        if (result.contains("사용 가능한")) {
          _nicknameCheck = true;
        }
        ;
        _nicknameError = result;
      });
    }
  }

  void _passwordValidCheckSetState(String passwordInput) {
    setState(() {
      _passwordCheck = false;
      _passwordInputForCheck = passwordInput;
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
          _passwordCheck = true;
        }
      }
    });
  }

  void _passwordCompareCheckSetState(String passwordCheckInput) {
    setState(() {
      _passwordCompareCheck = false;
      if (_passwordInputForCheck != passwordCheckInput) {
        _passwordCheckError = "비밀번호가 일치하지 않습니다.";
      } else {
        _passwordCheckError = null;
        _passwordCompareCheck = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 다른데 누르면 키보드 감춤
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("회원가입",
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            body: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
                    child: Center(
                      child: Column(
                        children: [
                          Stack(children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : AssetImage(
                                          'assets/default_profile_image.png')
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
                                                  EdgeInsets.fromLTRB(
                                                      8, 0, 8, 0)),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      TextButton(
                                        onPressed: _emailAlreadyExistsCheck,
                                        child: Text(
                                          "중복확인",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(color: blackColor),
                                        ),
                                        style: TextButton.styleFrom(
                                          minimumSize: Size(88, 45),
                                          backgroundColor: subPointColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
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
                                          ErrorTextWidget(
                                            errorMessage: _emailError,
                                          ),
                                        ],
                                      )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          PasswordWidget(
                              passwordValidCheckSetState:
                                  _passwordValidCheckSetState,
                              passwordCompareCheckSetState:
                                  _passwordCompareCheckSetState,
                              pwController: _pwController,
                              pwCheckController: _pwCheckController,
                              passwordError: _passwordError,
                              passwordCheckError: _passwordCheckError),
                          SizedBox(
                            height: 16,
                          ),
                          NicknameWidget(
                            nicknameValidCheckSetState:
                                _nicknameValidCheckSetState,
                            nicknameAlreadyExistsCheckSetState:
                                _nicknameAlreadyExistsCheckSetState,
                            nicknameError: _nicknameError,
                            nicknameCheck: _nicknameCheck,
                            nicknameController: _nicknameController,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          TextButton(
                            onPressed: _signup,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "회원가입",
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }
}
