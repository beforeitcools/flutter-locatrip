import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/model/advice_model2.dart';
import 'package:flutter_locatrip/advice/screen/editors_list_screen.dart';
import 'package:flutter_locatrip/common/model/json_parser.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AdvicePostScreen extends StatefulWidget {
  const AdvicePostScreen({Key? key}) : super(key: key);

  @override
  State<AdvicePostScreen> createState() => _AdvicePostScreenState();
}

class _AdvicePostScreenState extends State<AdvicePostScreen> {
  final AdviceModel2 _adviceModel = AdviceModel2();
  final JsonParser _jsonParser = JsonParser();

  final ScrollController _scrollController = ScrollController();
  bool _isBottomSheetVisible = false;
  bool _isSelected = false;

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;

  late int _tripId;
  late int _userId;

  Map<String, dynamic> _adviceAll = {};
  List<dynamic> _advicePlaceList = [];
  List<Map<String, dynamic>> _tripDayList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isBottom = _scrollController.position.pixels != 0;
        if (isBottom && !_isBottomSheetVisible) {
          setState(() {
            _isBottomSheetVisible = true;
          });
          _showBottomSheet();
        }
      }
    });

    _tripId = 1;
    _userId = 2;
    latitude = 37.493196;
    longitude = 127.028549;

    _loadData();
  }

  void _loadData() async {
    try {
      print('data$_tripId$_userId');
      Map<String, dynamic> result =
          await _adviceModel.selectAdviceList(context, _tripId, _userId);

      if (result.isNotEmpty) {
        print('result$result');

        _adviceAll = result["all"];
        _advicePlaceList = result["place"];
        _tripDayList = _jsonParser.convertToList(result["posts"]);

        print('_adviceAll $_adviceAll');
        print('_advicePlaceList $_advicePlaceList');
        print('_tripDayList $_tripDayList');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('에러메시지!! $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildVerticalDashedLine() {
    return Container(
      width: 1.5, // 점선의 너비를 고정
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 점선 시작 위치 설정
        children: List.generate(
          5, // 점선 길이 설정
          (index) => index.isEven
              ? Container(height: 4, color: grayColor)
              : Container(height: 4, color: Colors.transparent), // 점선 간격
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: pointBlueColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                      children: [
                        TextSpan(text: "나를 위한 현지인의 첨삭이 마음에 들었다면 해당 글을 "),
                        TextSpan(
                            text: "채택",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                        TextSpan(text: "해 보시는 건 어떨까요? 🥰"),
                      ])),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 바텀시트 닫기
                  // 채택하기 기능 추가
                  _onSelect();
                },
                child: Text(
                  '채택하러가기',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSelect() {
    setState(() {
      _isSelected = true; // 하이라이트 활성화
    });
  }

  // 날짜형식변환
  String dateFormat(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('y-M-d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '첨삭글',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                // 채택하기 기능 추가
                // 이미 채택되었으면 아무것도 하지 않음
                if (!_isSelected) {
                  _onSelect();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditorsListScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.recommend,
                color: _isSelected ? pointBlueColor : grayColor,
              ),
              label: Text(
                '채택하기',
                style: TextStyle(
                  color: _isSelected ? pointBlueColor : grayColor,
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _tripDayList != null
                ? SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        _buildMapSection(),
                        if (_adviceAll != null)
                          _buildMainAdviceCard(_adviceAll),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _tripDayList.length,
                            itemBuilder: (context, index) {
                              return Column(children: [
                                _buildSectionHeader(_tripDayList[index])
                              ]);
                            })
                      ],
                    ))
                : SizedBox.shrink());
  }

  /// 지도 섹션
  Widget _buildMapSection() {
    return Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // boxShadow: [
          //   BoxShadow(
          //     color: grayColor.withOpacity(0.3),
          //     spreadRadius: 2,
          //     blurRadius: 5,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: latitude != null && longitude != null
            ? Container(
                height: 260,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(latitude! - 0.005, longitude!), zoom: 13),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller; // 지도 컨트롤러 초기화
                  },
                  /*markers: _markers,
            polylines: _polylines,*/
                  gestureRecognizers: //
                      <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                      // () => ScaleGestureRecognizer(),
                    ),
                  },
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }

  Widget _buildMainAdviceCard(Map<String, dynamic> advice) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: grayColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자, 날짜, 프로필 이미지
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 프로필 아이콘
                const Icon(
                  Icons.account_circle,
                  size: 24,
                  color: grayColor,
                ),
                const SizedBox(width: 8),

                // 작성자와 날짜
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // advice['author'] ??
                        '작성자 없음',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        advice['createdAt'] != null
                            ? dateFormat(advice['createdAt'])
                            : "" ?? '날짜 없음',
                        style: const TextStyle(
                          fontSize: 12,
                          color: grayColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              advice['contents'] != null ? advice['contents'] : "",
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ));
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: pointBlueColor,
            child: Text(
              place["orderIndex"] != null ? place["orderIndex"].toString() : "",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place["location"]?["name"] != null
                    ? place["location"]["name"]
                    : "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          place["location"]?["category"] != null
                              ? place["location"]["category"]
                              : "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: grayColor,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(" · "),
                      Flexible(
                        child: Text(
                          place["location"]?["address"] != null
                              ? place["location"]["address"]
                              : "",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  /// 카드 섹션
  /// 게시글 카드 (작성자, 날짜, 프로필 이미지)
  Widget _buildAdviceCard(dynamic advice) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자, 날짜, 프로필 이미지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 아이콘
              const Icon(
                Icons.account_circle,
                size: 24,
                color: grayColor,
              ),
              const SizedBox(width: 8),

              // 작성자와 날짜
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '작성자 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      advice['createdAt'] ?? '날짜 없음',
                      style: const TextStyle(
                        fontSize: 12,
                        color: grayColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 게시글 내용
          Text(
            advice['contents'] ?? '내용 없음',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
