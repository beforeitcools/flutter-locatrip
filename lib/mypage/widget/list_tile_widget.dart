import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/mypage/widget/custom_dialog.dart';

class ListTileWidget extends StatefulWidget {
  int selectedIndex;
  List<dynamic> myTrips;

  ListTileWidget({
    super.key,
    required this.selectedIndex,
    required this.myTrips,
  });

  @override
  State<ListTileWidget> createState() => _ListTileWidgetState();
}

class _ListTileWidgetState extends State<ListTileWidget> {
  late int _selectedIndex;
  late List<dynamic> _myTrips;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _myTrips = widget.myTrips;
  }

  Widget _listTileCreator(int index) {
    // 해당 category의 index 와 선택된 index가 동일한지로 선택됨 여부 판단
    // bool isSelected = index == _selectedIndex;
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // 여행 게획 페이지로 연결
          splashColor: Color.fromARGB(50, 43, 192, 228),
          highlightColor: Color.fromARGB(30, 43, 192, 228),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Image.asset(
                  "assets/icon/delete.png",
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _myTrips[_selectedIndex][index]['title'],
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoSansKR',
                        ),
                        overflow: TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                          "${_myTrips[_selectedIndex][index]['startDate']} ~ ${_myTrips[_selectedIndex][index]['endDate']}",
                          style: Theme.of(context).textTheme.labelSmall),
                      SizedBox(
                        height: 1,
                      ),
                      Text("3명과 함께, 1개 도시",
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                InkWell(
                  onTap: () {
                    CustomDialog.show(context, "정말 삭제 하시겠습니까?", "삭제");
                  }, // 삭제
                  splashColor: Color.fromARGB(50, 43, 192, 228),
                  highlightColor: Color.fromARGB(30, 43, 192, 228),
                  child: Image.asset(
                    "assets/icon/delete.png",
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_myTrips.isNotEmpty && _myTrips[_selectedIndex].isNotEmpty) {
      return Column(
        children: List.generate(
          _myTrips[_selectedIndex].length,
          (index) => _listTileCreator(index),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Center(
          child: Text("여행이 없습니다."),
        ),
      );
    }
  }
}
