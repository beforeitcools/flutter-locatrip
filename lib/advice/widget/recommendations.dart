import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class Recommendations extends StatelessWidget {
  final List<dynamic> postsInMyRegion;
  final String localArea;
  /*final List<String> postTitles = [
    "가족끼리 경주여행",
    "친구랑 경주",
    "여행가긔",
    "여행코스 괜찮나 봐주실분"
  ];*/

  const Recommendations({
    super.key,
    required this.postsInMyRegion,
    required this.localArea,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 3, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: lightGrayColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: postsInMyRegion.isEmpty
                ? Row(
                    children: [
                      Text(
                        "$localArea 이/가 포함된 포스트가 없습니다.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                : Row(
                    children: postsInMyRegion.map((post) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            // 포스트 페이지로 연결(postId)
                            onTap: () {},
                            splashColor: Color.fromARGB(50, 43, 192, 228),
                            highlightColor: Color.fromARGB(30, 43, 192, 228),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: grayColor),
                                  child: Image.asset(
                                    "assets/icon/delete.png",
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Container(
                                  alignment: Alignment.center,
                                  width: 80,
                                  child: Text(
                                    post['title'],
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ));
  }
}
