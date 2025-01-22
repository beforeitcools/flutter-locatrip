import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/common/model/local_area_auth_controller.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';

class UserpageScreen extends StatefulWidget {
  final int userId;

  const UserpageScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserpageScreen> createState() => _UserpageScreenState();
}

class _UserpageScreenState extends State<UserpageScreen> {
  bool _isLoading = true;
  late final int userId;
  dynamic _userData;
  String? _profileImage;
  late String _nickname;
  late int _ownBadge;
  late String _selectedAdviceCount;
  late String _localArea = '';
  late String _badgelocalArea = '';
  final MypageModel _mypageModel = MypageModel();
  final ChatModel _chatModel = ChatModel();
  final LocalAreaAuthController _localAreaAuthController =
      LocalAreaAuthController();

  Future<void> _loadMypageData(int userId) async {
    try {
      LoadingOverlay.show(context);
      Map<String, dynamic> result =
          await _mypageModel.getUserPageData(context, userId);
      print(result);
      setState(() {
        _userData = result['user'];
        if (result['user'] != null) {
          _selectedAdviceCount = result['selectedAdviceCount'].toString();
          _profileImage = _userData['profilePic'];
          _nickname = _userData['nickname'] ?? '닉네임 없음';
          _ownBadge = _userData['ownBadge'];
          if (_userData['localAreaAuthDate'] != null &&
              (_localAreaAuthController.calculateDaysLeftUntilExpiration(
                      _userData['localAreaAuthDate']) >
                  0)) {
            print("오냐?????");
            _localArea = _userData['localArea'];
          }
          if (_ownBadge == 1) {
            _badgelocalArea = _userData['localArea'];
          }
          _isLoading = false;
        }
        print(_localArea);
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!유저페이지 로드 중 에러 발생 : $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _loadMypageData(userId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    child: _profileImage != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _profileImage!,
                              placeholder: (context, url) => SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.error_outline,
                                size: 48,
                              ),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                AssetImage('assets/default_profile_image.png')
                                    as ImageProvider),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.center,
                          _nickname,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NotoSansKR',
                          ),
                          overflow: TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: lightGrayColor,
                          width: 1.0,
                        )),
                    child: Column(
                      children: [
                        _localArea.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        "$_localArea 지킴이", // 수호자??
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'NotoSansKR',
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                        maxLines: 1,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        _ownBadge == 1
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        "독보적 $_badgelocalArea러",
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'NotoSansKR',
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Icon(
                                      Icons.verified_outlined,
                                      color: pointBlueColor,
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        Container(
                          height: 54,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                      color: lightGrayColor,
                                      width: 1.0,
                                    ),
                                  )),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/icon/editor_choice.png",
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      "내 첨삭 채택수",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    SizedBox(
                                      height: 16,
                                      width: 40,
                                      child: VerticalDivider(
                                        color: grayColor,
                                        thickness: 1.0,
                                      ),
                                    ),
                                    Text(/*_selectedAdviceCount*/ '31',
                                        style: TextStyle(
                                          color: pointBlueColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      /*TODO 채팅 기능 넣어!!!!!!!!!!!!!*/ _chatModel
                          .chattingRoomForOTO(userId, _nickname, context);
                    },
                    icon: Icon(Icons.sms_outlined),
                    label: Text(
                      "채팅하기",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}
