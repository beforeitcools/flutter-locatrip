import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_locatrip/advice/screen/post_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/trip/model/trip_day_model.dart';
import 'package:flutter_locatrip/trip/screen/share_screen.dart';
import 'package:flutter_locatrip/trip/widget/edit_close_modal.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:provider/provider.dart';

import '../../checklist/screen/checklist_screen.dart';
import '../../expense/screen/expense_screen.dart';
import '../../main/model/main_screen_provider.dart';
import '../../map/model/custom_marker.dart';
import '../../map/model/place.dart';

import '../model/trip_model.dart';
import '../widget/drag_bottom_sheet.dart';
import '../widget/edit_bottom_sheet.dart';
import '../widget/trip_share_bottom_sheet.dart';

class TripViewScreen extends StatefulWidget {
  final int tripId;

  const TripViewScreen({super.key, required this.tripId});

  @override
  State<TripViewScreen> createState() => _TripViewScreenState();
}

class _TripViewScreenState extends State<TripViewScreen> {
  final TripModel _tripModel = TripModel();
  final TripDayModel _tripDayModel = TripDayModel();
  final MypageModel _mypageModel = MypageModel();

  late final int userId;

  late String _nickName;

  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  final ScrollController _singleScrollController = ScrollController();
  final ScrollController bottomScrollController = ScrollController();

  Map<String, dynamic> tripInfo = {};

  bool isLoading = true;

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  String address = "";

  // 드롭다운 날짜
  List<String> _dropDownDay = [];

  late double _containerHeight;

  double _animatedPositionedOffset = 0;
  bool _isTop = false;

  bool _isInfoLoaded = false;

  List<Map<String, dynamic>> tripDayAllList = [];
  Map<int, List<Map<String, dynamic>>> groupedTripDayAllList = {};

  final colors = [
    pointBlueColor,
    Colors.purple,
    Colors.pink,
    Colors.green,
    Colors.amber,
  ];

  final Map<int, BitmapDescriptor> _iconCache = {};
  String? _focusedMarkerId; // 현재 포커스된 마커 ID

  bool isEditing = false; // 편집 여부

  List<String> _tripUsersProfileList = [];

  bool _unreadAlarmExists = false;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('ko_KR', null).then((_) {
      Intl.defaultLocale = 'ko_KR';
      if (!_isInfoLoaded) {
        _isInfoLoaded = true;
        _loadInfo();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final screenHeight = MediaQuery.of(context).size.height;
        _containerHeight = screenHeight - 450; //62
      });
    });

    _singleScrollController.addListener(() {
      setState(() {
        _animatedPositionedOffset = _singleScrollController.offset;

        if (_animatedPositionedOffset > 64) {
          _isTop = true;
        } else {
          _isTop = false;
        }
      });
    });
  }

  // 정보 로드
  void _loadInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> result =
          await _tripModel.selectTrip(widget.tripId, context);

      if (result.isNotEmpty) {
        setState(() {
          tripInfo.addAll(result["trip"]);
          _unreadAlarmExists = result["unreadAlarmExists"];

          // 참여 중인 유저 프로필 이미지
          for (Map<String, dynamic> tripUser in tripInfo["tripUsers"]) {
            String _profilePic = tripUser["user"]["profilePic"] == null
                ? "null"
                : tripUser["user"]["profilePic"];
            _tripUsersProfileList.add(_profilePic);
          }

          // 선택한 지역 중 첫번째 찾기
          String? regionWithOrderIndexZero;

          for (Map<String, dynamic> items in tripInfo['selectedRegions']) {
            if (items['orderIndex'] == 0) {
              regionWithOrderIndexZero = items['region'];
              break;
            }
          }

          address = regionWithOrderIndexZero!;

          isLoading = false;

          // 여행 정보가 로드된 이후 드롭다운 목록 업데이트
          getDropDownDayList();
        });

        if (address.isNotEmpty) {
          _getCoordinatesFromAddress();
        }

        await _loadTripDayLocation();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("에러메시지1 : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _preloadMarkers(List<Map<String, dynamic>> tripDayAllList) async {
    for (var tripDay in tripDayAllList) {
      if (tripDay["place"] != null) {
        int orderIndex = tripDay["orderIndex"] ?? 1;
        int colorIndex = (orderIndex - 1) % colors.length;
        await _getCustomMarkerIcon(orderIndex, colors[colorIndex]);
      }
    }
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(int orderIndex, Color color,
      {bool isFocused = false}) async {
    // 캐싱 키 생성 (포커스 여부를 구분하기 위해 음수 변형)
    final cacheKey = isFocused ? -orderIndex : orderIndex;

    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    // 아이콘 생성 후 캐싱
    final ByteData byteData = await createCustomMarkerIconImage(
      text: orderIndex.toString(),
      size: isFocused ? const Size(100, 100) : const Size(72, 72), // 크기 조정
      color: color,
    );
    final Uint8List imageData = byteData.buffer.asUint8List();
    final BitmapDescriptor customMarker = BitmapDescriptor.fromBytes(imageData);

    _iconCache[cacheKey] = customMarker;
    return customMarker;
  }

  // 확대된 마커 (다시 찍음)
  void _onMarkerTap(String markerId, List<Map<String, dynamic>> tripDayAllList,
      int dateIndex) async {
    setState(() {
      _focusedMarkerId = markerId; // 현재 선택된 마커 ID 업데이트
    });

    // 마커 업데이트
    final List<Marker> updatedMarkers = [];
    final List<LatLng> markerPositions = [];
    for (var tripDay in tripDayAllList) {
      if (tripDay["dateIndex"] == dateIndex && tripDay["place"] != null) {
        final bool isFocused = tripDay["place"].id == markerId;
        int orderIndex = tripDay["orderIndex"] ?? 1;
        int colorIndex = (orderIndex - 1) % colors.length;

        final BitmapDescriptor icon = await _getCustomMarkerIcon(
          orderIndex,
          colors[colorIndex],
          isFocused: isFocused,
        );
        markerPositions.add(tripDay["place"].location);

        updatedMarkers.add(
          Marker(
              markerId: MarkerId(tripDay["place"].id ?? ""),
              position: LatLng(
                tripDay["place"].location.latitude ?? 0.0,
                tripDay["place"].location.longitude ?? 0.0,
              ),
              icon: icon,
              zIndex: isFocused ? 10 : 1,
              onTap: () {
                _onMarkerTap(tripDay["place"].id!, tripDayAllList, dateIndex);
                mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(tripDay["place"].location.latitude,
                          tripDay["place"].location.longitude),
                      12.0),
                );
              }),
        );

        if (isFocused) {
          latitude = tripDay["place"].location.latitude;
          longitude = tripDay["place"].location.longitude;
        }
        _moveMapToCurrentLocation();
      }
    }

    final newPolylines = {
      if (markerPositions.isNotEmpty)
        Polyline(
          polylineId: PolylineId("path_$dateIndex"),
          points: markerPositions,
          color: grayColor,
          width: 1,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
    };

    setState(() {
      _markers = updatedMarkers.toSet(); // 마커 목록 갱신
      _polylines = newPolylines;
    });
  }

  // 날짜별 일정 불러오기
  Future<void> _loadTripDayLocation() async {
    int tripId = tripInfo["id"];

    try {
      List<Map<String, dynamic>> result =
          await _tripDayModel.getTripDay(tripId, context);

      if (result != null && result.isNotEmpty) {
        tripDayAllList.clear();
        for (Map<String, dynamic> resultItem in result) {
          Map<String, dynamic> resultMap = {
            "id": resultItem["id"],
            "tripId": resultItem["tripId"],
            "locationId": resultItem["locationId"],
            "date": resultItem["date"],
            "visitTime": resultItem["visitTime"],
            "orderIndex": resultItem["orderIndex"],
            "memo": resultItem["memo"],
            "expenseId": resultItem["expenseId"],
            "dateIndex": resultItem["dateIndex"],
            "isChecked": false,
            "place": Place(
                id: resultItem["location"]["googleId"],
                name: resultItem["location"]["name"],
                address: resultItem["location"]["address"],
                category: resultItem["location"]["category"],
                photoUrl: null,
                location: LatLng(resultItem["location"]["latitude"],
                    resultItem["location"]["longitude"]),
                icon: BitmapDescriptor.defaultMarker),
            "sortIndex": resultItem["sortIndex"]
          };
          tripDayAllList.add(resultMap);
        }
        await _selectMemo();

        // 마커 캐싱
        _preloadMarkers(tripDayAllList);
        _updateMarkersAndPolylines(tripDayAllList, 0); // 첫째날 마커

        // 상태 변경 후 UI 갱신
        setState(() {
          groupedTripDayAllList =
              groupByDate(tripDayAllList, _dropDownDay.length);

          latitude = groupedTripDayAllList[0]?[0]["place"].location.latitude;
          longitude = groupedTripDayAllList[0]?[0]["place"].location.longitude;
          print("!!latitude: $latitude longitude: $longitude");
          _moveMapToCurrentLocation();
        });
      } else {
        print('결과가 없거나 null입니다.');
        await _selectMemo();

        setState(() {
          groupedTripDayAllList =
              groupByDate(tripDayAllList, _dropDownDay.length);
        });
      }
    } catch (e) {
      print('에러메시지2 $e');
      // return {};
    }
  }

  // 마커 & 폴리라인 찍기
  Future<void> _updateMarkersAndPolylines(
      List<Map<String, dynamic>> tripDayAllList, int dateIndex) async {
    final List<Marker> tempMarkers = [];
    final List<LatLng> markerPositions = [];

    for (var tripDay in tripDayAllList) {
      if (tripDay["dateIndex"] == dateIndex && tripDay["place"] != null) {
        int orderIndex = tripDay["orderIndex"] ?? 1;
        int colorIndex = (orderIndex - 1) % colors.length;
        final BitmapDescriptor customMarker =
            await _getCustomMarkerIcon(orderIndex, colors[colorIndex]);
        markerPositions.add(tripDay["place"].location);

        tempMarkers.add(
          Marker(
            markerId: MarkerId(tripDay["place"].id ?? ""),
            position: LatLng(
              tripDay["place"].location.latitude ?? 0.0,
              tripDay["place"].location.longitude ?? 0.0,
            ),
            icon: customMarker,
            zIndex: 1,
            onTap: () {
              // _focusOnMarker(tripDay["dateIndex"], tripDay["orderIndex"] - 1);
              _onMarkerTap(tripDay["place"].id, tripDayAllList, dateIndex);
            },
          ),
        );
      }
    }

    final newPolylines = {
      if (markerPositions.isNotEmpty)
        Polyline(
          polylineId: PolylineId("path_$dateIndex"),
          points: markerPositions,
          color: grayColor,
          width: 1,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
    };

    setState(() {
      _markers = tempMarkers.toSet(); // 중복 제거 및 Set 변환
      _polylines = newPolylines; // Set<Polyline>
    });
  }

  Map<int, List<Map<String, dynamic>>> groupByDate(
      List<Map<String, dynamic>> list, int totalDays) {
    // 빈 Map 생성
    Map<int, List<Map<String, dynamic>>> groupedMap = {};

    // 초기화: 모든 인덱스를 빈 리스트로 설정
    for (int i = 0; i < totalDays; i++) {
      groupedMap[i] = [];
    }

    // 리스트의 데이터를 그룹화
    for (var item in list) {
      print('item $item');
      int dateIndex = item['dateIndex']; // dateIndex를 키로 사용
      groupedMap[dateIndex]?.add(item); // 해당 키에 데이터 추가
    }

    print('groupedMap $groupedMap');
    return groupedMap;
  }

  // 메모 불러오기
  Future<void> _selectMemo() async {
    try {
      List<Map<String, dynamic>> selectMemoList =
          await _tripModel.selectMemo(tripInfo["id"], context);
      if (selectMemoList != null) {
        print('메모 조회 성공');

        List<Map<String, dynamic>> tempList = [];
        for (Map<String, dynamic> memo in selectMemoList) {
          Map<String, dynamic> newDayPlace = {};
          newDayPlace["id"] = memo["id"];
          newDayPlace["isMemo"] = true;
          newDayPlace["memo"] = memo["content"];
          newDayPlace["dateIndex"] = memo["dateIndex"];
          newDayPlace["sortIndex"] = memo["sortIndex"];
          newDayPlace["isChecked"] = false;
          tempList.add(newDayPlace);
        }
        // _dayPlaceList.addAll(tempList);
        tripDayAllList.addAll(tempList);
        print('new tripDayAllList $tripDayAllList');
      }
    } catch (e) {
      print("에러메시지3 $e");
    }
  }

  // 이름으로 위도/경도 불러오기
  _getCoordinatesFromAddress() async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);

      setState(() {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
        print('현재 지역 latitude$latitude longitude$longitude');
        tripInfo['latitude'] = locations.first.latitude;
        tripInfo['longitude'] = locations.first.longitude;
      });

      _moveMapToCurrentLocation();
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

  // 현재 위치로 이동
  void _moveMapToCurrentLocation() {
    if (latitude != null && longitude != null && mapController != null) {
      // print("latitude2: $latitude longitude: $longitude");
      mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(latitude!, longitude!)),
      );
    }
  }

  // 시작/끝 날짜 사이값 구하기
  List<DateTime> getDatesBetween(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime current = start;

    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(Duration(days: 1));
    }

    return dates;
  }

  // 여행기간 날짜 리스트
  List<String> getDropDownDayList() {
    _dropDownDay.clear(); // 중복 추가 방지

    DateTime _startDate = tripInfo['startDate'] != null
        ? DateTime.parse(tripInfo['startDate'])
        : DateTime.now();

    DateTime _endDate = tripInfo['endDate'] != null
        ? DateTime.parse(tripInfo['endDate'])
        : _startDate;

    List<DateTime> _dateList = getDatesBetween(_startDate, _endDate);
    setState(() {
      for (var date in _dateList) {
        var dateFormat = DateFormat('MM.dd').format(date).toString();
        var dayOfWeek = DateFormat('E', 'ko_KR').format(date).toString();
        String dropDownItem = "$dateFormat/$dayOfWeek";
        _dropDownDay.add(dropDownItem);
      }
    });
    return _dropDownDay;
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "날짜 없음";
    DateTime date = DateTime.parse(dateString);
    return DateFormat('y년 M월 d일').format(date);
  }

  void updateEditingState(bool value) {
    setState(() {
      isEditing = value;
    });
  }

  // 첨삭받기 버튼 눌렀을 때
  void _addPostOrShowModal() async {
    int tripId = tripInfo["id"];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(20),
            actionsPadding: EdgeInsets.all(5),
            insetPadding: EdgeInsets.all(30),
            title: Text(
              "여행 첨삭 기능안내",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            content: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: blackColor, // 기본 텍스트 색상
                      height: 1.5, // 줄 간격
                    ),
                children: [
                  TextSpan(
                    text: "나만의 여정, 현지인에게 확인해 보세요!\n",
                  ),
                  TextSpan(
                    text: "현지인들의 생생한 경험을 바탕으로 여행 일정을 완성해보세요.\n\n",
                  ),
                  TextSpan(
                      text: "단, 게시글 작성 후에 일정 변경 시 여행첨삭소에는 반영되지않습니다.\n\n",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  TextSpan(
                      text: "지금 게시글을 등록하시겠습니까?",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
                  child: Text(
                    "취소",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: grayColor, fontWeight: FontWeight.w500),
                  )),
              TextButton(
                  onPressed: () {
                    _isPossibleWrite();
                  },
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
                  child: Text(
                    "확인",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: pointBlueColor, fontWeight: FontWeight.w500),
                  ))
            ],
          );
        });

    /*int count = await _tripDayModel.getTripDayCount(tripId, context);
      if (count >= 3) {
        // 첨삭소로 이동
        Navigator.push(
            // 뭔가 넘겨줘야하나????
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(tripId: tripId)));
      } else if (count < 3) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                actionsPadding: EdgeInsets.all(5),
                content: Text(
                  "첨삭글을 작성하려면 3개 이상의 장소를 등록하세요.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "확인",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: pointBlueColor, fontWeight: FontWeight.w500),
                      ))
                ],
              );
            });
      }*/
  }

  // 첨삭받기 버튼 눌렀을 때
  void _isPossibleWrite() async {
    int tripId = tripInfo["id"];
    try {
      int count = await _tripDayModel.getTripDayCount(tripId, context);
      if (count >= 3) {
        // 첨삭소로 이동
        Navigator.push(
            // 뭔가 넘겨줘야하나????
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(tripId: tripId)));
      } else if (count < 3) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                actionsPadding: EdgeInsets.all(5),
                content: Text(
                  "첨삭글을 작성하려면 3개 이상의 장소를 등록하세요.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "확인",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: pointBlueColor, fontWeight: FontWeight.w500),
                      ))
                ],
              );
            });
      }
    } catch (e) {
      print('에러메시지4 $e');
    }
  }

  void _share() async {
    // 사용자 정의 템플릿 ID
    int templateId = 116405;
    // 카카오톡 실행 가능 여부 확인
    bool isKakaoTalkSharingAvailable =
        await kakao.ShareClient.instance.isKakaoTalkSharingAvailable();

    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final dynamic stringId = await _storage.read(key: 'userId');
    String userId = stringId;
    print('로그인 중인 userId $userId');

    String region = "";
    int regionLength = 0;
    int tripId = 0;
    String elseString = "";

    if (tripInfo.isNotEmpty) {
      // 닉네임 찾아 오는 로직
      _getMyNickname();

      if (_nickName.isNotEmpty) {
        // 선택한 지역
        region = tripInfo["selectedRegions"][0]["region"];
        regionLength = tripInfo["selectedRegions"].length - 1;
        elseString = regionLength == 0 ? "" : " 외 ${regionLength}개";

        // 일정ID
        tripId = tripInfo["id"];
      }
    }

    Map<String, String> templateArgs = {
      'USER': _nickName,
      'TRIP': '${region}${elseString} 도시 여행',
      'tripId': '$tripId',
      'userId': userId
    };

    if (isKakaoTalkSharingAvailable) {
      try {
        Uri uri = await kakao.ShareClient.instance
            .shareCustom(templateId: templateId, templateArgs: templateArgs);
        await kakao.ShareClient.instance.launchKakaoTalk(uri);
        print('카카오톡 공유 완료');
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    } else {
      try {
        Uri shareUrl = await kakao.WebSharerClient.instance
            .makeCustomUrl(templateId: templateId, templateArgs: templateArgs);
        await kakao.launchBrowserTab(shareUrl, popupOpen: true);
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    }
  }

  void _getMyNickname() async {
    try {
      Map<String, dynamic> result = await _mypageModel.getMyPageData(context);
      if (result.isNotEmpty) {
        print('result $result');
        _nickName = result["user"]['nickname'];
      }
    } catch (e) {
      print('에러메시지5 $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateRange = tripInfo['startDate'] == tripInfo['endDate']
        ? "${formatDate(tripInfo['startDate'])}"
        : "${formatDate(tripInfo['startDate'])} ~ ${formatDate(tripInfo['endDate'])}";

    double screenHeight = MediaQuery.of(context).size.height;

    print('!?!latitude $latitude');

    // isEditing이 true일 때 스크롤 위치를 설정
    if (isEditing) {
      double targetOffset = 172;
      targetOffset = targetOffset.clamp(
          _singleScrollController.position.minScrollExtent,
          _singleScrollController.position.maxScrollExtent);
      _singleScrollController.jumpTo(targetOffset);
    }

    String defaultImageUrl = "assets/default_profile_image.png";
    return WillPopScope(
        onWillPop: () {
          setState(() {
            Provider.of<MainScreenProvider>(context, listen: false)
                .triggerReload();
            Navigator.popUntil(context, (route) => route.isFirst);
          });
          return Future(() => false);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  if (isEditing) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return EditCloseModal();
                        });
                  } else {
                    Provider.of<MainScreenProvider>(context, listen: false)
                        .triggerReload();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                icon: Icon(Icons.arrow_back)),
            title: _isTop
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tripInfo["title"] ?? "제목 없음",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        dateRange,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: grayColor),
                      )
                    ],
                  )
                : isEditing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            tripInfo["title"],
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(dateRange,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: grayColor))
                        ],
                      )
                    : SizedBox.shrink(),
            actions: [
              isEditing
                  ? IconButton(
                      onPressed: null,
                      icon: Icon(Icons.ios_share),
                      color: blackColor.withOpacity(0.2),
                    )
                  : IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => TripShareBottomSheet());
                      },
                      icon: Icon(Icons.ios_share)),
              isEditing
                  ? IconButton(
                      onPressed: null,
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_outlined),
                          // 새로운 알림 여부

                          if (_unreadAlarmExists)
                            Positioned(
                              right: -1,
                              top: 1,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                              ),
                            )
                        ],
                      ),
                      color: blackColor.withOpacity(0.2),
                    )
                  : IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_outlined)),
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : tripInfo.isEmpty
                  ? Center(child: Text("여행 정보를 불러올 수 없습니다."))
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _singleScrollController,
                          physics: isEditing
                              ? NeverScrollableScrollPhysics()
                              : AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5, // 최대 너비 설정
                                                    ),
                                                    child: IntrinsicWidth(
                                                      child: Text(
                                                        tripInfo["title"] ??
                                                            "제목 없음",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        showModalBottomSheet(
                                                            context: context,
                                                            builder: (context) =>
                                                                EditBottomSheet());
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        minimumSize: Size(
                                                          0,
                                                          0,
                                                        ),

                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap, // 터치 영역 최소화
                                                      ),
                                                      child: Text(
                                                        "편집",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: grayColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ))
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                dateRange,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: grayColor),
                                              ),
                                            ]),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            gradient: LinearGradient(
                                              colors: [
                                                pointBlueColor,
                                                subPointColor
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              if (tripInfo["chattingId"] !=
                                                  null) {
                                                // 채팅방 들어가기
                                              } else {
                                                // 채팅방 만들기
                                              }
                                            },
                                            icon: Icon(
                                              Icons.sms_outlined,
                                              color: Colors.white,
                                            ),
                                            iconSize: 28,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        if (_tripUsersProfileList.isNotEmpty)
                                          ..._tripUsersProfileList
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;

                                            return Transform.translate(
                                              offset: Offset(
                                                  index == 0
                                                      ? 0
                                                      : -10.0 * index,
                                                  0),
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                  child: Image.asset(
                                                    entry.value.toString() ??
                                                        defaultImageUrl,
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                        defaultImageUrl,
                                                        width: 32,
                                                        height: 32,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        Transform.translate(
                                          offset:
                                              _tripUsersProfileList.isNotEmpty
                                                  ? Offset(
                                                      -10.0 *
                                                          _tripUsersProfileList
                                                              .length,
                                                      0)
                                                  : Offset(0, 0),
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ShareScreen(
                                                              title: tripInfo[
                                                                  "title"],
                                                              num:
                                                                  _tripUsersProfileList
                                                                      .length,
                                                              share: _share)));
                                            },
                                            style: TextButton.styleFrom(
                                                backgroundColor: pointBlueColor,
                                                minimumSize: Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding: EdgeInsets.fromLTRB(
                                                    8, 6, 12, 6),
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Colors.white)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.add,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  _tripUsersProfileList
                                                          .isNotEmpty
                                                      ? "일행 초대"
                                                      : "일행과 함께 짜기",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChecklistScreen(
                                                          tripId:
                                                              tripInfo["id"],
                                                          userId: userId),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.fromLTRB(
                                                  12, 6, 12, 6),
                                              backgroundColor: lightGrayColor,
                                              minimumSize: Size(
                                                0,
                                                0,
                                              ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text("체크리스트",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: grayColor))),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExpenseScreen(
                                                          tripId:
                                                              tripInfo["id"]),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.fromLTRB(
                                                  12, 6, 12, 6),
                                              backgroundColor: lightGrayColor,
                                              minimumSize: Size(
                                                0,
                                                0,
                                              ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text("가계부",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: grayColor))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (latitude != null && longitude != null)
                                Container(
                                  height: 260,
                                  child: GoogleMap(
                                    zoomControlsEnabled: false,
                                    zoomGesturesEnabled: true,
                                    initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            latitude! - 0.005, longitude!),
                                        zoom: 13),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      mapController = controller; // 지도 컨트롤러 초기화
                                    },
                                    markers: _markers,
                                    polylines: _polylines,
                                    gestureRecognizers: //
                                        <Factory<OneSequenceGestureRecognizer>>{
                                      Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                        // () => ScaleGestureRecognizer(),
                                      ),
                                    },
                                  ),
                                )
                              else
                                Center(child: CircularProgressIndicator()),
                              Container(
                                height: screenHeight - (80 + 260), // 앱바+지도
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        // 슬라이드 컨텐츠

                        DragBottomSheet(
                          dropDownDay: _dropDownDay,
                          tripInfo: tripInfo,
                          animatedPositionedOffset: _animatedPositionedOffset,
                          containerHeight: _containerHeight,
                          singleScrollController: _singleScrollController,
                          groupedTripDayAllList: groupedTripDayAllList,
                          bottomScrollController: bottomScrollController,
                          colors: colors,
                          updateMarkersAndPolylines: _updateMarkersAndPolylines,
                          onMarkerTap: _onMarkerTap,
                          isEditing: isEditing,
                          onEditingChange: updateEditingState,
                          mapController: mapController,
                        )
                      ],
                    ),
          floatingActionButton: isEditing
              ? SizedBox.shrink()
              : Container(
                  width: 68,
                  height: 65,
                  child: FloatingActionButton(
                    onPressed: _addPostOrShowModal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                        ),
                        Text(
                          "첨삭받기",
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
