import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/widget/date_bottom_sheet.dart';

import '../screen/search_place_screen.dart';

class DayWidget extends StatefulWidget {
  final dynamic selectedItem;
  final List<String> dropDownDay;
  final int index;
  final Function(int) onDateSelected;
  final Map<String, dynamic> tripInfo;
  final int selectedIndex;

  const DayWidget(
      {super.key,
      required this.selectedItem,
      required this.dropDownDay,
      required this.index,
      required this.onDateSelected,
      required this.tripInfo,
      required this.selectedIndex});

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  late List<String> dropDownDayList;
  dynamic _selectedItem;
  late int index;
  late Map<String, dynamic> _tripInfo;
  late int _selectedIndex;
  // 모든 day가 담김
  List<Map<String, dynamic>> dayPlaceList = [];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    dropDownDayList = widget.dropDownDay;
    index = widget.index;
    _tripInfo = widget.tripInfo;
    _selectedIndex = widget.selectedIndex;
    print('_selectedIndex $_selectedIndex');
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
                  onPressed: () async {
                    _tripInfo["day"] = index;

                    final Map<String, dynamic> receiver = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchPlaceScreen(
                                  tripInfo: _tripInfo,
                                )));

                    print('receiver $receiver');
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
