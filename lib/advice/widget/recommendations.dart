import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/post_view_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

import '../../trip/model/recommend_region.dart';

class Recommendations extends StatelessWidget {
  final List<dynamic> postsInMyRegion;
  final String localArea;

  const Recommendations({
    super.key,
    required this.postsInMyRegion,
    required this.localArea,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: postsInMyRegion.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$localArea 이/가 포함된 포스트가 없습니다.",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: postsInMyRegion.map((post) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 4.5,
                          padding: EdgeInsets.all(5),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              // 포스트 페이지로 연결(postId)
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PostViewScreen(
                                            postId: post['postId'])));
                              },
                              splashColor: Color.fromARGB(50, 43, 192, 228),
                              highlightColor: Color.fromARGB(30, 43, 192, 228),
                              child: Column(
                                children: [
                                  Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: grayColor),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          regionImages.keys.contains(localArea)
                                              ? "${regionImages[localArea]}"
                                              : "assets/images/default.jpg",
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                  SizedBox(height: 7),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 80,
                                    child: Text(
                                      post['title'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
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
            Container(
              height: 1,
              color: lightGrayColor,
              margin: EdgeInsets.symmetric(horizontal: 16),
            )
          ],
        ));
  }
}
