import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/model/advice_model.dart';
import 'package:flutter_locatrip/advice/model/post_model.dart';
import 'package:flutter_locatrip/advice/screen/advice_view_screen.dart';
import 'package:flutter_locatrip/advice/screen/advice_write_screen.dart';
import 'package:flutter_locatrip/advice/screen/editors_list_screen.dart';
import 'package:flutter_locatrip/advice/widget/trip_for_advice.dart';
import 'package:flutter_locatrip/common/model/json_parser.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostViewScreen extends StatefulWidget {
  // post id는 query parameter로 가지고 있을 거기 때문에 만약에 필요한 애들이 있으면은 거기서 가져와주면 되긔 ...
  // 포스트 타이틀이랑 포스트는 어케 가져와염 그냥 포스트 번호를 넘겨받어?

  final int postId;
  PostViewScreen({super.key, required this.postId});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  bool _isLoading = true;
  String _tripData = "";

  final PostModel _postModel = PostModel();
  final JsonParser _jsonParser = JsonParser();
  final AdviceModel _adviceModel = AdviceModel();

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  int _myUserId = 0;
  String _authenticatedLocalArea = '';
  List<dynamic> _selectedRegionList = [];
  bool _isLocal = false;
  bool _isUserAndPostCreatorSame = false;
  bool _canAdvice = false;
  dynamic _postData = [];

  Future<void> _getUserId() async {
    final dynamic stringId = await _storage.read(key: 'userId');
    setState(() {
      _isLoading = true;
      _myUserId = int.tryParse(stringId) ?? 0; // 현재 유저 아이디
    });
  }

  // 로그인한 유저의 현지인 인증이 유효한지 검사
  Future<Map<String, dynamic>> checkUserLocalAreaAuthIsValid() async {
    try {
      Map<String, dynamic> isValidAndLocalArea =
          await _adviceModel.checkUserLocalAreaAuthIsValid(context);
      print(isValidAndLocalArea);
      return isValidAndLocalArea;
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!현지인 인증 유효성 검증중  에러 발생 : $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('현지인 인증 유효성 검증중 오류가 발생했습니다. 다시 시도해주세요.')));
      return {"isValid": false, "localArea": null};
    }
  }

  void _initPostData(int postId) async {
    //query parameter로 넘겨주는 postID
    _postData = await _postModel.getPostById(postId, context);
    // 로그인한 유저의 현지인 인증이 유효한지 검사
    Map<String, dynamic> isValidAndLocalArea =
        await checkUserLocalAreaAuthIsValid();
    // 유효성 여부 통과 확인
    if (!isValidAndLocalArea['isValid']) {
      _isLocal = false;
    } else {
      _authenticatedLocalArea = isValidAndLocalArea['localArea'];
      // _postData 로 selectedRegions 의 Region 가져와서 _selectedRegionList 에 add
      for (var p in _postData) {
        // _postData[i]["selectedRegions"]["region"]의 저장된 모든 region 저장... 이걸 원하신 게 맞나요
        // 아닐시 조건문을 ...
        _selectedRegionList.add(p["selectedRegions"]["region"]);
      }
    }
    if (_selectedRegionList.contains(_authenticatedLocalArea)) {
      _isLocal = true;
    }
    _isUserAndPostCreatorSame = _myUserId == _postData['userId'];

    if (_isUserAndPostCreatorSame == false && _isLocal == true) {
      _canAdvice = true;
    }

    print('여행 넘겨 받았어?!?!?!   $_postData');
    _updateValue(_postData["advicedTripData"]);
  }

  void _updateValue(String value) {
    setState(() {
      _tripData = value;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    _initPostData(widget.postId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Pass true when the back button is pressed
          Navigator.pop(context, true);
          return false; // Prevent default back navigation
        },
        child: Stack(
          children: [
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Image.asset(
                    'assets/splash_screen_image.gif',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            Scaffold(
                appBar: AppBar(
                  actions: [
                    if (_isUserAndPostCreatorSame)
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // 수정/ 삭제
                          // _showOptions(context);
                        },
                      ),
                  ],
                ),
                body: _tripData.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                child: _postData == null
                                    ? Center(child: CircularProgressIndicator())
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Text(_postData["title"],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge),
                                            SizedBox(height: 16),
                                            Text(_postData["contents"],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium),
                                            SizedBox(height: 24),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                ElevatedButton(
                                                    onPressed:
                                                        _isUserAndPostCreatorSame
                                                            ? () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                EditorsListScreen(postId: widget.postId)));
                                                              }
                                                            : () {},
                                                    style: ElevatedButton.styleFrom(
                                                        elevation: 0,
                                                        minimumSize:
                                                            Size(140, 45),
                                                        backgroundColor:
                                                            _isUserAndPostCreatorSame
                                                                ? pointBlueColor
                                                                : grayColor),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text("채택하러가기 ",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .labelLarge!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white)),
                                                        Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.white,
                                                            size: 18)
                                                      ],
                                                    ))
                                              ],
                                            )
                                          ])),
                            SizedBox(height: 16),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 60,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: lightGrayColor, blurRadius: 4)
                                    ],
                                    color: Colors.white),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("전체 첨삭",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      IconButton(
                                          onPressed: () {
                                            /*바텀시트*/ showAdviceBottomSheet(
                                                widget.postId,
                                                0,
                                                "",
                                                _canAdvice);
                                          },
                                          icon: Icon(Icons.forum_outlined,
                                              color: blackColor))
                                    ])),
                            SizedBox(height: 16),
                            Expanded(
                                child: _tripData.isEmpty
                                    ? Center(child: CircularProgressIndicator())
                                    : TripForAdvice(
                                        tripData: _tripData,
                                        postId: widget.postId,
                                        canAdvice: _canAdvice,
                                      ))
                          ],
                        ),
                      )),
          ],
        ));
  }

  void showAdviceBottomSheet(
      int postId, int tripDayLocationId, String locationName, bool canAdvice) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canAdvice)
                  TextButton(
                      onPressed: () {
                        /*TODO 첨삭하기 페이지*/
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdviceWriteScreen(
                                    postId: postId,
                                    tripDayLocationId: tripDayLocationId,
                                    locationName: locationName)));
                      },
                      child: Text(
                        "첨삭하기",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: blackColor),
                      )),
                TextButton(
                    onPressed: () {
                      /*TODO 첨삭보기 페이지*/
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdviceViewScreen(
                                    postId: postId,
                                    tripDayLocationId: tripDayLocationId,
                                  )));
                    },
                    child: Text("첨삭보기",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: blackColor))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("취소",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: blackColor))),
              ],
            ),
          );
        });
  }
}
