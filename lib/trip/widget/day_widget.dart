import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/trip_day_model.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';
import 'package:flutter_locatrip/trip/widget/date_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';

import '../screen/search_place_screen.dart';

class DayWidget extends StatefulWidget {
  final dynamic selectedItem;
  final List<String> dropDownDay;
  final int index;
  final Function(int) onDateSelected;
  final Map<String, dynamic> tripInfo;
  final int selectedIndex;

  const DayWidget({
    super.key,
    required this.selectedItem,
    required this.dropDownDay,
    required this.index,
    required this.onDateSelected,
    required this.tripInfo,
    required this.selectedIndex,
  });

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  final TripDayModel _tripDayModel = TripDayModel();
  late List<String> dropDownDayList;
  dynamic _selectedItem;
  late int index;
  late Map<String, dynamic> _tripInfo;
  late int _selectedIndex;

  // 모든 day가 담김
  List<Map<String, dynamic>> _dayPlaceList = [];
  Map<String, dynamic> _dayPlace = {};

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    dropDownDayList = widget.dropDownDay;
    index = widget.index;
    _tripInfo = widget.tripInfo;
    _selectedIndex = widget.selectedIndex;

    print('tripInfo $_tripInfo');
    /*
    * tripInfo {id: 16, userId: 1, title: ㅇ허ㅣ, startDate: 2025-01-16, endDate: 2025-01-24, createdAt: 2025-01-09T21:31:54, updatedAt: 2025-01-09T21:31:54, chattingId: null, status: 1, selectedRegions: [{tripId: 16, region: 여수}]}
    * */
    print('dropDownDayList $dropDownDayList');
    /*
    * dropDownDayList [01.16/목, 01.17/금, 01.18/토, 01.19/일, 01.20/월, 01.21/화, 01.22/수, 01.23/목, 01.24/금]
    * */
  }

  void _showBottomSheet(BuildContext context, dropDownDayList, index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      enableDrag: false,
      barrierColor: Colors.black.withOpacity(0.32), // scrim
      isScrollControlled: true,
      // isDismissible: false,  // 바깥 터치로 닫기 비활성화
      builder: (BuildContext context) {
        return Container(
            constraints: BoxConstraints(
              // minHeight: MediaQuery.of(context).size.height * 0.3,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: DateBottomSheet(
                dropDownDayList: dropDownDayList,
                index: index,
                onItemSelected: (selectedIndex) {
                  widget.onDateSelected(selectedIndex); // 선택된 날짜로 스크롤 이동
                  Navigator.pop(context); // 바텀시트 닫기
                },
              ),
            ));
      },
    );
  }

  Widget getWidget(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "day${index + 1}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(
              width: 8,
            ),
            index == 0
                ? TextButton(
                    onPressed: () {
                      _showBottomSheet(context, dropDownDayList, index);
                    },
                    style: TextButton.styleFrom(
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedItem,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: grayColor,
                                  ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: blackColor,
                        ),
                      ],
                    ),
                  )
                : Text(
                    dropDownDayList[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500, color: grayColor),
                  )
          ],
        ),
        index == 0
            ? TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "편집",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: grayColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
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

  void _saveTripDayLocation() async {
    DateTime startDate = DateTime.parse(_tripInfo["startDate"]);
    DateTime endDate = DateTime.parse(_tripInfo["endDate"]);
    List<DateTime> dates = getDatesBetween(startDate, endDate);
    Map<String, dynamic> data = {
      "tripId": _tripInfo["id"],
      "name": _dayPlace["name"],
      "date": dates[_dayPlace["day"]]
    };

    try {
      Map<String, dynamic> result =
          await _tripDayModel.saveTripDayLocation(data, context);
      if (result.isNotEmpty) {
        print('result $result');
      }
    } catch (e) {
      print('에러메시지 $e');
    }

    // 1.장소가 없으면 장소 저장 - 있으면 저장x  -> 장소 이름 넘겨서 아이디 찾기
    // 2. 일정 id trip_view_screen 에서 받아오기
    // 3. place 로 저장.. // 이름 주소 카테고리 위도 경도
    // 저장 후에 tripDayLocation Id값도 반환받아서 갖고 있기
  }

  // 두 지점 간 거리 계산
  Future<double> calculateDistance(
      double startLat, double startLng, double endLat, double endLng) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
  /*
  * double distance = await calculateDistance(
                place1Lat, place1Lng, place2Lat, place2Lng);*/

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    _tripInfo["day"] = index;

    final Map<String, dynamic> receiver = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchPlaceScreen(
                  tripInfo: _tripInfo,
                )));

    print('receiver $receiver');
    setState(() {
      _dayPlace = {
        "name": receiver["place"].name, // 장소명
        "address": receiver["place"].address,
        "category": receiver["place"].category,
        "location": receiver["place"].location,
        "day": receiver["day"]
      };
    });

    _saveTripDayLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.all(16), child: getWidget(index)),

        // 여기에 장소 추가/ 메모 추가 되면 됨 !

        Row(
          children: [
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: OutlinedButton(
                  onPressed: () {
                    _navigateAndDisplaySelection(context);
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: grayColor,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: EdgeInsets.all(6),
                      minimumSize: Size(
                        0,
                        0,
                      )),
                  child: Text(
                    "장소추가",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: blackColor),
                  )),
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: grayColor,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: EdgeInsets.all(6),
                      minimumSize: Size(
                        0,
                        0,
                      )),
                  child: Text(
                    "메모추가",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: blackColor),
                  )),
            ),
            SizedBox(
              width: 16,
            ),
          ],
        ),
      ],
    );
  }
}
