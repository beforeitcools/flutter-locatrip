import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class MypostsListTileWidget extends StatelessWidget {
  final List<dynamic> myPosts;

  const MypostsListTileWidget({super.key, required this.myPosts});

  Widget _listTileCreator(int index, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // 내가 쓴 포스트 페이지로 연결  myPosts[index]['id'] 넘겨주면 될듯?
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
                            myPosts[index]['title'],
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
                          myPosts[index]['regionCount'] == 1
                              ? Text(
                                  "${myPosts[index]['region']} • ${myPosts[index]['startDate']} ~ ${myPosts[index]['endDate']}",
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
                                  "${myPosts[index]['regionCount']}개 지역 • ${myPosts[index]['startDate']} ~ ${myPosts[index]['endDate']}",
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
                          SizedBox(
                            height: 1,
                          ),
                          Text(
                            myPosts[index]['contents'],
                            style: TextStyle(
                              color: grayColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'NotoSansKR',
                            ),
                            overflow:
                                TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
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
    if (myPosts.isNotEmpty) {
      return Column(
        children: List.generate(
          myPosts.length,
          (index) => _listTileCreator(index, context),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: Text("작성한 포스트가 없습니다."),
        ),
      );
    }
  }
}
