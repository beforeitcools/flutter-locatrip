import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';

import '../../advice/screen/advice_post_screen.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final MypageModel _mypageModel = MypageModel();
  late List<dynamic> _alarmList;
  bool _isLoading = true;
  List<Map<String, dynamic>> _alarmListForshow = [
    {
      "image": "assets/local_advice.png",
      "title": "현지인 첨삭",
      "content": "'제주도 가족여행일정 좀 봐주세요!! 3박4일'의 혼자옵서예 님이 첨삭을 등록했습니다."
    },
    {
      "image": "assets/add_user.png",
      "title": "일정합류",
      "content": "Kdaughter 님이 초대한 남준 님이 제주도 가족여행에 참여했습니다. 함께 여행을 준비해 보세요."
    }
  ];

  Future<void> _loadMyAlarmData() async {
    try {
      LoadingOverlay.show(context);
      List<dynamic> alarmData = await _mypageModel.getMyAlarmData(context);
      print("result: $alarmData");

      setState(() {
        _alarmList = alarmData;
        print("_alarmList: $_alarmList");
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!알림 중 에러 발생 : $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadMyAlarmData();
  }

  Widget _listTileCreator(int index, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // 여행 게획 페이지로 연결
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdvicePostScreen()),
          );
        },
        splashColor: Color.fromARGB(50, 43, 192, 228),
        highlightColor: Color.fromARGB(30, 43, 192, 228),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.asset(
                      _alarmListForshow[index]['image'],
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _alarmListForshow[index]['title'],
                      style: TextStyle(
                        color: grayColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSansKR',
                      ),
                      overflow: TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      _alarmListForshow[index]['content'],
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /*if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }*/

    return Scaffold(
        appBar: AppBar(
          title: Text("알림", style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: List.generate(
              _alarmListForshow.length,
              (index) => _listTileCreator(index, context),
            ),
            /*mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          // 여행 게획 페이지로 연결
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdvicePostScreen()),
                            );
                          },
                          splashColor: Color.fromARGB(50, 43, 192, 228),
                          highlightColor: Color.fromARGB(30, 43, 192, 228),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: Image.asset(
                                          "assets/icon/rate_review.png",
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          _alarmListForshow[0]['title'],
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          _alarmListForshow[0]['content'],
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          // 여행 게획 페이지로 연결
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdvicePostScreen()),
                            );
                          },
                          splashColor: Color.fromARGB(50, 43, 192, 228),
                          highlightColor: Color.fromARGB(30, 43, 192, 228),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: Image.asset(
                                          "assets/icon/rate_review.png",
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          _alarmListForshow[1]['title'],
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          _alarmListForshow[1]['content'],
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'NotoSansKR',
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ]),
              )
            ],*/
          ),
        ));
  }
}
