import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class MyadvicesListTileWidget extends StatelessWidget {
  final List<dynamic> myAdvices;

  const MyadvicesListTileWidget({super.key, required this.myAdvices});

  Widget _listTileCreator(int index, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // 내가 쓴 포스트 페이지로 연결
        splashColor: Color.fromARGB(50, 43, 192, 228),
        highlightColor: Color.fromARGB(30, 43, 192, 228),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: lightGrayColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            myAdvices[index]['title'],
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'NotoSansKR',
                            ),
                            overflow:
                                TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: 1,
                          ),
                          myAdvices[index]['regionCount'] == 1
                              ? Text(
                                  "${myAdvices[index]['nickname']}님의 일정 • ${myAdvices[index]['region']} • ${myAdvices[index]['startDate']} ~ ${myAdvices[index]['endDate']}",
                                  style: TextStyle(
                                    color: grayColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'NotoSansKR',
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                  maxLines: 1,
                                )
                              : Text(
                                  "${myAdvices[index]['nickname']}님의 일정 • ${myAdvices[index]['regionCount']}개 도시 • ${myAdvices[index]['startDate']} ~ ${myAdvices[index]['endDate']}",
                                  style: TextStyle(
                                    color: grayColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'NotoSansKR',
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // 텍스트 삐져나옴 방지(길면...)
                                  maxLines: 1,
                                ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icon/editor_choice.png",
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "채택됨",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (myAdvices.isNotEmpty) {
      return Column(
        children: List.generate(
          myAdvices.length,
          (index) => _listTileCreator(index, context),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: Text("작성한 첨삭이 없습니다."),
        ),
      );
    }
  }
}
