import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/model/auth_model.dart';
import 'package:flutter_locatrip/Auth/widget/image_pick_widget.dart';
import 'package:flutter_locatrip/Auth/widget/nickname_widget.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/splash_screen_for_loading.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  String? _profileImage;
  File? _image;
  final TextEditingController _nicknameController = TextEditingController();
  String? _nicknameError;
  bool _nicknameCheck = false;
  late final String _unchangedNickname;
  final AuthModel _authModel = AuthModel();
  final MypageModel _mypageModel = MypageModel();

  @override
  void initState() {
    super.initState();
    LoadingOverlay.show();
    _loadMypageData();
    LoadingOverlay.hide();
  }

  void _loadMypageData() async {
    Map<String, dynamic> result = await _mypageModel.getMyPageData(context);
    setState(() {
      _profileImage = result['user']['profilePic'];
      _nicknameController.text = result['user']['nickname'];
      _unchangedNickname = result['user']['nickname'];
      _nicknameCheck = true;

      print(_profileImage);
      print(_nicknameController.text);
    });
  }

  void _selectImage(XFile pickedFile) {
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _nicknameValidCheckSetState(String nicknameInput) {
    setState(() {
      _nicknameCheck = false;

      if (RegExp(r'^[가-힣]{1,10}$').hasMatch(nicknameInput) ||
          RegExp(r'^[A-Za-z0-9]{2,20}$').hasMatch(nicknameInput)) {
        _nicknameError = null;
      } else {
        _nicknameError = "한글 1~10자, 영문 2~20자 이내, 특수문자 불가";
      }
    });
  }

  void _nicknameAlreadyExistsCheckSetState() async {
    if (_unchangedNickname == _nicknameController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("현재 사용중인 닉네임 입니다.")));
      setState(() {
        _nicknameCheck = true;
      });
    } else if (_nicknameController.text.isEmpty) {
      setState(() {
        _nicknameError = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("닉네임 형식에 맞아야 중복 확인 가능합니다.")));
    } else if (_nicknameError != null && _nicknameError!.contains("불가")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("닉네임 형식에 맞아야 중복 확인 가능합니다.")));
    } else {
      String result = await _authModel.checkNickname(_nicknameController.text);
      setState(() {
        if (result.contains("사용 가능한")) {
          _nicknameCheck = true;
        }
        _nicknameError = result;
      });
    }
  }

  void _updateProfile() async {
    if (_nicknameCheck == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("중복 확인을 완료 해야 합니다.")));
    } else {
      Map<String, String> updatedData = {'nickname': _nicknameController.text};

      try {
        String result =
            await _mypageModel.updateProfile(updatedData, _image, context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));
        Navigator.pop(context, true);
        // Navigator.pushReplacementNamed(context, "/login"); // 성공시 로그인 screen     // 마이페이지 이동 체크
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 다른데 누르면 키보드 감춤
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text("프로필 수정", style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 165,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            child: _image != null
                                ? CircleAvatar(
                                    radius: 60,
                                    backgroundImage: FileImage(_image!),
                                  )
                                : _profileImage != null
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: _profileImage!,
                                          placeholder: (context, url) =>
                                              SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error_outline,
                                            size: 96,
                                          ),
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: AssetImage(
                                                'assets/default_profile_image.png')
                                            as ImageProvider),
                          ),
                          ImagePickWidget(selectImage: _selectImage)
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      NicknameWidget(
                        nicknameValidCheckSetState: _nicknameValidCheckSetState,
                        nicknameAlreadyExistsCheckSetState:
                            _nicknameAlreadyExistsCheckSetState,
                        nicknameError: _nicknameError,
                        nicknameCheck: _nicknameCheck,
                        nicknameController: _nicknameController,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextButton(
                        onPressed: _updateProfile,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "수정 완료",
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
        ),
      ),
    );
  }
}
