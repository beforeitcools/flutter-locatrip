import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/trip_day_model.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';
import 'package:flutter_locatrip/trip/widget/date_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../map/model/place.dart';
import '../screen/search_place_screen.dart';

class DayWidget extends StatefulWidget {
  final dynamic selectedItem;
  final List<String> dropDownDay;
  final int index;
  final Function(int) onDateSelected;
  final Map<String, dynamic> tripInfo;
  final int selectedIndex;
  final List<Map<String, dynamic>> dayPlaceList;
  final List colors;
  final ScrollController scrollController;
  final Function(double) onHeightCalculated;
  final Future<void> Function(List<Map<String, dynamic>>, int)
      updateMarkersAndPolylines;

  const DayWidget(
      {required this.selectedItem,
      required this.dropDownDay,
      required this.index,
      required this.onHeightCalculated,
      required this.onDateSelected,
      required this.tripInfo,
      required this.selectedIndex,
      required this.dayPlaceList,
      required this.colors,
      required this.scrollController,
      required this.updateMarkersAndPolylines});

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  Map<String, GlobalKey> _listKeys = {};
  late double _itemHeight; // listTile height

  final TripDayModel _tripDayModel = TripDayModel();
  final TripModel _tripModel = TripModel();
  TextEditingController _memoController = TextEditingController();

  late List<String> dropDownDayList;
  dynamic _selectedItem;
  late int index;
  late Map<String, dynamic> _tripInfo;
  late int _selectedIndex;
  late Map<int, List<Map<String, dynamic>>> _groupedTripDayAllList;
  late List _colors;

  // 모든 day가 담김
  late List<Map<String, dynamic>> _dayPlaceList;
  Map<String, dynamic> _dayPlace = {};

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    dropDownDayList = widget.dropDownDay;
    index = widget.index;
    _tripInfo = widget.tripInfo;
    _selectedIndex = widget.selectedIndex;
    _dayPlaceList = widget.dayPlaceList;
    _colors = widget.colors;
    _scrollController = widget.scrollController;

    sortDayPlaceListBySortIndex();

    for (var i = 0; i < _dayPlaceList.length; i++) {
      final key =
          '${_dayPlaceList[i]["dateIndex"]}-${_dayPlaceList[i]["sortIndex"]}';
      if (!_listKeys.containsKey(key)) {
        _listKeys[key] = GlobalKey();
      }
    }

    // 프레임 렌더링 이후 높이를 계산
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateItemHeight();
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      widget.onHeightCalculated(size.height); // 부모로 높이 값 전달
    });

    _initialScrollController();
  }

  void _initialScrollController() {
    _scrollController.addListener(() {
      /* print('scrollOffset ${_scrollController.offset}');
      if (_dayPlaceList != null) {
        print('dateIndex $index');
      }*/
    });
  }

  // 높이 계산 함수
  void _calculateItemHeight() {
    print('_listKeys $_listKeys');
    if (_dayPlaceList.isNotEmpty && _listKeys.isNotEmpty) {
      // 첫 번째 항목의 높이를 측정
      for (var i = 0; i < _dayPlaceList.length; i++) {
        final RenderBox? renderBox = _listKeys[
                '${_dayPlaceList[i]["dateIndex"]}-${_dayPlaceList[i]["sortIndex"]}']
            ?.currentContext
            ?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          setState(() {
            _itemHeight = renderBox.size.height;
            print("Item height: $_itemHeight");
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant DayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상위 위젯에서 데이터가 변경된 후 이를 처리
    if (widget.colors != oldWidget.colors) {
      setState(() {
        _colors = widget.colors;
      });
    }
  }

  // 정렬 순서로 정렬
  void sortDayPlaceListBySortIndex() {
    setState(() {
      _dayPlaceList.sort((a, b) {
        return (a["sortIndex"] ?? 0).compareTo(b["sortIndex"] ?? 0);
      });
    });
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
      "googleId": _dayPlace["place"].id,
      "tripId": _tripInfo["id"],
      "name": _dayPlace["place"].name,
      "address": _dayPlace["place"].address,
      "latitude": _dayPlace["place"].location.latitude,
      "longitude": _dayPlace["place"].location.longitude,
      "category": _dayPlace["place"].category,
      "date": dates[_dayPlace["day"]].toIso8601String(),
      "dateIndex": _dayPlace["day"],
      "sortIndex": _dayPlaceList.length
    };

    try {
      Map<String, dynamic> result =
          await _tripDayModel.saveTripDayLocation(data, context);
      print('saveTripDayLocation결과 $result');
      if (result.isNotEmpty) {
        setState(() {
          if (!_dayPlaceList.any((place) => place["id"] == result["id"])) {
            _dayPlace["id"] = result["id"];
            _dayPlace["tripId"] = result["tripId"];
            _dayPlace["locationId"] = result["locationId"];
            _dayPlace["date"] = result["date"];
            _dayPlace["visitTime"] = result["visitTime"];
            _dayPlace["orderIndex"] = result["orderIndex"];
            _dayPlace["memo"] = result["memo"];
            _dayPlace["expenseId"] = result["expenseId"];
            _dayPlace["isChecked"] = false;
            _dayPlace["dateIndex"] = result["dateIndex"];
            _dayPlace["isMemo"] = false;
            _dayPlace["sortIndex"] = result["sortIndex"];

            _dayPlaceList.add(_dayPlace);

            widget.updateMarkersAndPolylines(
                _dayPlaceList, result["dateIndex"]);
          } else {
            print("이미 추가된 장소입니다.");
          }
        });
      }
    } catch (e) {
      print('에러메시지 $e');
    }

    // 1.장소가 없으면 장소 저장 - 있으면 저장x  -> 장소 이름 넘겨서 아이디 찾기 ㅇ
    // 2. 일정 id trip_view_screen 에서 받아오기 - tripInfo에 있음 ㅇ
    // 3. place 로 저장.. // 이름 주소 카테고리 위도 경도
    // 저장 후에 tripDayLocation Id 값도 반환받아서 갖고 있기
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

    setState(() {
      Place selectedPlace = receiver['place'];
      _dayPlace = {
        "place": selectedPlace,
        "day": receiver["day"],
        "dateIndex": receiver["dateIndex"]
      };
    });

    _saveTripDayLocation();
  }

  void _addMemo(Map<String, dynamic> data) async {
    try {
      Map<String, dynamic> addMemoResult =
          await _tripModel.addMemo(data, context);
      if (addMemoResult.isNotEmpty) {
        print('메모 등록 성공');
        setState(() {
          Map<String, dynamic> newMemo = {
            "isMemo": true,
            "memo": addMemoResult["content"],
            "dateIndex": addMemoResult["dateIndex"],
            "isChecked": false,
            "sortIndex": addMemoResult["sortIndex"]
          };

          // 기존 _dayPlaceList에 새로운 객체 추가
          _dayPlaceList.add(newMemo);
        });
      }
    } catch (e) {
      print("에러메시지 $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.all(16), child: getWidget(index)),

        // 여기에 장소 추가/ 메모 추가 되면 됨 !
        if (_dayPlaceList != null)
          ..._dayPlaceList.map((item) {
            if (item["isMemo"] == true) {
              // 메모일 경우
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: ListTile(
                    key: _listKeys['${item["dateIndex"]}-${item["sortIndex"]}'],
                    contentPadding: EdgeInsets.only(left: 14),
                    horizontalTitleGap: 6,
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pointBlueColor,
                      ),
                      width: 8,
                      height: 8,
                    ),
                    title: FractionallySizedBox(
                        widthFactor: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: Offset(1, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            item["memo"] ?? "메모가 없습니다.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )),
                  ));
            } else {
              int colorIndex = (item["orderIndex"] - 1) % _colors.length;
              // 장소일 경우
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: ListTile(
                      key: ValueKey(item["sortIndex"]),
                      contentPadding: EdgeInsets.only(left: 6),
                      horizontalTitleGap: 16,
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _colors[colorIndex],
                        ),
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Text(
                          item["orderIndex"]?.toString() ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                        ),
                      ),
                      title: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width -
                                (6 + 16 + 24 + 32),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["place"]?.name ?? "",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Wrap(
                                    spacing: 2,
                                    children: [
                                      Text(
                                        item["place"]?.category ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: grayColor),
                                      ),
                                      if (item["place"]?.category != null &&
                                          item["place"]?.address != null)
                                        Text(
                                          "·",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: grayColor),
                                        ),
                                      Text(
                                        item["place"]?.address?.split(" ")[0] ??
                                            "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: grayColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          /*SizedBox(width: 10),*/
                          // 텍스트
                        ],
                      )));
            }
          }).toList(),

        // 편집 모드
        /*if (_dayPlaceList != null)
          Container(
              child: ReorderableListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;

                final item = _dayPlaceList.removeAt(oldIndex);
                _dayPlaceList.insert(newIndex, item);

                // orderIndex 업데이트 (메모는 제외)
                int orderIndex = 1;
                for (int i = 0; i < _dayPlaceList.length; i++) {
                  if (_dayPlaceList[i]["isMemo"] != true) {
                    _dayPlaceList[i]["orderIndex"] = orderIndex++;
                  }
                }
                for (int i = 0; i < _dayPlaceList.length; i++) {
                  _dayPlaceList[i]["sortIndex"] = i + 1;
                }
              });
            },
            children: [
              for (int i = 0; i < _dayPlaceList.length; i++)
                if (_dayPlaceList[i]["isMemo"] == true)
                  // 메모 항목
                  ListTile(
                    key: ValueKey('memo_$i'),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    horizontalTitleGap: 0,
                    leading: IconButton(
                      onPressed: () {
                        setState(() {
                          if (_dayPlaceList[i]["isChecked"] != null) {
                            _dayPlaceList[i]["isChecked"] =
                                !_dayPlaceList[i]["isChecked"];
                          }
                        });
                      },
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _dayPlaceList[i]["isChecked"] == true
                              ? pointBlueColor
                              : Colors.white,
                          border: Border.all(
                            color: _dayPlaceList[i]["isChecked"] == true
                                ? pointBlueColor
                                : grayColor,
                            width: 1,
                          ),
                        ),
                        child: _dayPlaceList[i]["isChecked"] == true
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    title: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.545,
                            child: Text(
                              _dayPlaceList[i]["memo"] ?? "메모가 없습니다.",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Icon(
                            Icons.menu,
                            color: grayColor,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // 장소 항목
                  ListTile(
                    key: ValueKey(_dayPlaceList[i]),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    horizontalTitleGap: 0,
                    leading: IconButton(
                      onPressed: () {
                        setState(() {
                          if (_dayPlaceList[i]["isChecked"] != null) {
                            _dayPlaceList[i]["isChecked"] =
                                !_dayPlaceList[i]["isChecked"];
                          }
                        });
                      },
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _dayPlaceList[i]["isChecked"] == true
                              ? pointBlueColor
                              : Colors.white,
                          border: Border.all(
                            color: _dayPlaceList[i]["isChecked"] == true
                                ? pointBlueColor
                                : grayColor,
                            width: 1,
                          ),
                        ),
                        child: _dayPlaceList[i]["isChecked"] == true
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    title: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // 순서
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grayColor,
                                ),
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                child: Text(
                                  _dayPlaceList[i]["orderIndex"]?.toString() ??
                                      "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(width: 10),
                              // 텍스트
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _dayPlaceList[i]["place"]?.name ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Wrap(
                                      spacing: 2,
                                      children: [
                                        Text(
                                          _dayPlaceList[i]["place"]?.category ??
                                              "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: grayColor),
                                        ),
                                        if (_dayPlaceList[i]["place"]
                                                    ?.category !=
                                                null &&
                                            _dayPlaceList[i]["place"]
                                                    ?.address !=
                                                null)
                                          Text(
                                            "·",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(color: grayColor),
                                          ),
                                        Text(
                                          _dayPlaceList[i]["place"]
                                                  ?.address
                                                  ?.split(" ")[0] ??
                                              "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: grayColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.menu,
                            color: grayColor,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          )),*/

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
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "메모",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            content: TextField(
                              controller: _memoController,
                              maxLength: 50,
                              style: Theme.of(context).textTheme.bodySmall,
                              decoration: InputDecoration(
                                hintText: "잊기 쉬운 정보들을 메모해보세요.",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: grayColor),
                                border: InputBorder.none,
                              ),
                              maxLines: 4,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  _memoController.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "취소",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: grayColor,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  String memoText = _memoController.text;
                                  // 확인 버튼 클릭 시 처리할 로직
                                  print("입력된 메모: $memoText");
                                  print(
                                      ' 메모_dayPlaceList.length ${_dayPlaceList.length}');

                                  Map<String, dynamic> data = {
                                    "id": _tripInfo["id"],
                                    "content": memoText,
                                    "dateIndex": index,
                                    "sortIndex": _dayPlaceList.length
                                  };

                                  _addMemo(data);

                                  _memoController.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "확인",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: pointBlueColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                              ),
                            ],
                          );
                        });
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
