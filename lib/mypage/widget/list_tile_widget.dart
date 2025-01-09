import 'package:flutter/material.dart';

class ListTileWidget extends StatefulWidget {
  int selectedIndex;
  List<Map<String, dynamic>> myTrips;

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
  late List<Map<String, dynamic>> _myTrips;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _myTrips = widget.myTrips;
  }

  Widget _listTileCreator(int index) {
    // 해당 category의 index 와 선택된 index가 동일한지로 선택됨 여부 판단
    bool isSelected = index == _selectedIndex;
    return Expanded(
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              splashColor: Color.fromARGB(50, 43, 192, 228),
              highlightColor: Color.fromARGB(30, 43, 192, 228),
              child: Container(
                alignment: Alignment.center,
                height: 80,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Row(children: [
                    Image.asset(
                      "assets/icon/delete.png",
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      children: [
                        Text(
                          _myTrips[_selectedIndex]['title'],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                            "${_myTrips[_selectedIndex]['startDate']} ~ ${_myTrips[_selectedIndex]['endDate']}"),
                        SizedBox(
                          height: 6,
                        ),
                        Text("3명과 함께, 1개 도시"),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Spacer(),
          Image.asset(
            "assets/icon/delete.png",
            width: 24,
            height: 24,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_myTrips.isNotEmpty && _myTrips[_selectedIndex].isNotEmpty) {
      return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: List.generate(
              _myTrips[_selectedIndex].length,
              (index) => _listTileCreator(index),
            ),
          ));
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
