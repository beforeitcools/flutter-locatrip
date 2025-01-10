import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/mypage/widget/custom_dialog.dart';

class MytripListTileWidget extends StatelessWidget {
  final int selectedIndex;
  final List<dynamic> myTrips;
  final Future<void> Function(int tripId) deleteTrip;

  const MytripListTileWidget({
    super.key,
    required this.selectedIndex,
    required this.myTrips,
    required this.deleteTrip,
  });

  Widget _listTileCreator(int index, BuildContext context) {
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
                        myTrips[selectedIndex][index]['title'],
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
                          "${myTrips[selectedIndex][index]['startDate']} ~ ${myTrips[selectedIndex][index]['endDate']}",
                          style: Theme.of(context).textTheme.labelSmall),
                      SizedBox(
                        height: 1,
                      ),
                      myTrips[selectedIndex][index]['memberCount'] == 0
                          ? Text(
                              "${myTrips[selectedIndex][index]['regionCount']}개 도시",
                              style: Theme.of(context).textTheme.labelSmall)
                          : Text(
                              "${myTrips[selectedIndex][index]['memberCount']}명과 함께, ${myTrips[selectedIndex][index]['regionCount']}개 도시",
                              style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                myTrips[selectedIndex][index]['isCreator'] == true
                    ? InkWell(
                        onTap: () {
                          CustomDialog.show(
                            context,
                            "정말 삭제 하시겠습니까?",
                            "삭제",
                            () => deleteTrip(
                                myTrips[selectedIndex][index]['tripId']),
                          );
                        }, // 삭제
                        splashColor: Color.fromARGB(50, 244, 67, 54),
                        highlightColor: Color.fromARGB(30, 244, 67, 54),
                        borderRadius: BorderRadius.circular(20),
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Image.asset(
                            "assets/icon/delete.png",
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (myTrips.isNotEmpty && myTrips[selectedIndex].isNotEmpty) {
      return Column(
        children: List.generate(
          myTrips[selectedIndex].length,
          (index) => _listTileCreator(index, context),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: Text("여행이 없습니다."),
        ),
      );
    }
  }
}
