import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../model/trip_model.dart';
import '../widget/drag_bottom_sheet.dart';

class TripViewScreen extends StatefulWidget {
  final int tripId;

  const TripViewScreen({super.key, required this.tripId});

  @override
  State<TripViewScreen> createState() => _TripViewScreenState();
}

class _TripViewScreenState extends State<TripViewScreen> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  final ScrollController _singleScrollController = ScrollController();

  Map<String, dynamic> tripInfo = {};

  TripModel _tripModel = TripModel();
  bool isLoading = true;

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;

  String address = "";

  // 드롭다운 날짜
  List<String> _dropDownDay = [];

  late double _containerHeight;

  double _animatedPositionedOffset = 0;
  bool _isTop = false;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('ko_KR', null).then((_) {
      Intl.defaultLocale = 'ko_KR';
      _loadInfo();
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
        // print('_animatedPositionedOffset $_animatedPositionedOffset');
        if (_animatedPositionedOffset > 0) {
          _isTop = true;
        } else {
          _isTop = false;
        }
      });
    });
  }

  void _loadInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> result =
          await _tripModel.selectTrip(widget.tripId, context);
      if (result.isNotEmpty) {
        setState(() {
          tripInfo.addAll(result);

          // print('tripInfo ${tripInfo['selectedRegions']}');
          address = tripInfo['selectedRegions'][0]['region'];

          isLoading = false;

          // 여행 정보가 로드된 이후 드롭다운 목록 업데이트
          getDropDownDayList();
        });

        if (address.isNotEmpty) {
          _getCoordinatesFromAddress();
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("에러메시지 : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  _getCoordinatesFromAddress() async {
    try {
      List<Location> locations = await locationFromAddress(address);

      setState(() {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
        // print("latitude: $latitude longitude: $longitude");

        tripInfo['latitude'] = locations.first.latitude;
        tripInfo['longitude'] = locations.first.longitude;
      });

      _moveMapToCurrentLocation();
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    String dateRange = tripInfo['startDate'] == tripInfo['endDate']
        ? "${formatDate(tripInfo['startDate'])}"
        : "${formatDate(tripInfo['startDate'])} ~ ${formatDate(tripInfo['endDate'])}";

    double screenHeight = MediaQuery.of(context).size.height;

    // print('animatedPositionedOffset $_animatedPositionedOffset');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              // **추가해야함 ! 뒤로 가기 클릭했을 때 마이페이지 or 홈으로 이동 시키기...!!!
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MyPage()),
              //       (Route<dynamic> route) => false,
              // );
              Navigator.pop(context);
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
            : SizedBox.shrink(),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.ios_share)),
          IconButton(
              onPressed: () {}, icon: Icon(Icons.notifications_outlined)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                tripInfo["title"] ?? "제목 없음",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),

                                              // 권한 있는 사람만 편집가능 - 나중에 확인 !
                                              TextButton(
                                                  onPressed: () {},
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
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
                                                              FontWeight.w600,
                                                        ),
                                                  )),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            dateRange,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: grayColor),
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
                                          if (tripInfo["chattingId"] != null) {
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
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: pointBlueColor,
                                    minimumSize: Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "일행과 함께 짜기",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding:
                                              EdgeInsets.fromLTRB(12, 6, 12, 6),
                                          backgroundColor: lightGrayColor,
                                          minimumSize: Size(
                                            0,
                                            0,
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text("체크리스트",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: grayColor))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding:
                                              EdgeInsets.fromLTRB(12, 6, 12, 6),
                                          backgroundColor: lightGrayColor,
                                          minimumSize: Size(
                                            0,
                                            0,
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text("가계부",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: grayColor))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (latitude != null && longitude != null)
                            Container(
                              height: 260,
                              // height: MediaQuery.of(context).size.height - 250,
                              // // (80 + 172),
                              child: GoogleMap(
                                zoomControlsEnabled: true,
                                zoomGesturesEnabled: true,
                                initialCameraPosition: CameraPosition(
                                    target:
                                        LatLng(latitude! - 0.005, longitude!),
                                    zoom: 9),
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller; // 지도 컨트롤러 초기화
                                },
                                gestureRecognizers: //
                                    <Factory<OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                    // () => EagerGestureRecognizer(),
                                    () => ScaleGestureRecognizer(),
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
                    )
                  ],
                ),
      floatingActionButton: Container(
        width: 68,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            // 첨삭받기로 이동 !!
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => TripScreen(),
            //       fullscreenDialog: true,
            //     ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
              ),
              Text(
                "첨삭받기",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
