import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/post_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/recommend_region.dart';

class PostBottomSheet extends StatefulWidget {
  final List<dynamic> trips;

  const PostBottomSheet({
    super.key,
    required this.trips,
  });

  @override
  State<PostBottomSheet> createState() => _PostBottomSheetState();
}

class _PostBottomSheetState extends State<PostBottomSheet> {
  late List<dynamic> _trips;
  /*final List<Map<String, String>> myTripLists = [
    {'title': '부산 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '제주 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '서울 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '광주 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '대전 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
  ];*/

  List<bool> _isPressed = [];
  late int _selectedTripId;

  @override
  void initState() {
    super.initState();
    _trips = widget.trips;
    _isPressed = List.generate(_trips.length, (index) => false);
  }

  void _updateClickState(int index, bool isPressed) {
    setState(() {
      _isPressed[index] = isPressed;
      _selectedTripId = _trips[index]['tripId'];
      print(_selectedTripId);
    });
  }

  void _resetState() {
    for (int i = 0; i < _isPressed.length; i++) {
      if (_isPressed[i] = true) {
        setState(() {
          _isPressed[i] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
          child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height * 0.6) - 110,
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("여행 선택", style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: 16),
                Expanded(
                    child: ListView.builder(
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(
                                    color: lightGrayColor, width: 1)),
                            child: ListTile(
                              onTap: () {
                                _resetState();
                                _updateClickState(index, true);
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Image.asset(
                                  regionImages.keys
                                          .contains(trip['selectedRegion'])
                                      ? "${regionImages['${trip['selectedRegion']}']}"
                                      : "assets/icon/delete.png",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                trip["title"],
                                style: !_isPressed[index]
                                    ? Theme.of(context).textTheme.labelMedium
                                    : Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: pointBlueColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                "${trip['startDate']} - ${trip['endDate']}",
                                style: !_isPressed[index]
                                    ? Theme.of(context).textTheme.labelMedium
                                    : Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: pointBlueColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: _isPressed[index]
                                  ? Icon(
                                      Icons.check,
                                      color: pointBlueColor,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          );
                        }))
              ],
            ),
          ),
          Spacer(),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 80), // Full-width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  backgroundColor: pointBlueColor),
              onPressed: () {
                /* 글쓰기 페이지 */
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PostScreen(tripId: _selectedTripId)));
              },
              child: Text("첨삭받기",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white)))
        ],
      )),
    );
  }
}
