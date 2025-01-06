import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class Recommendations extends StatefulWidget {
  const Recommendations({super.key});

  @override
  State<Recommendations> createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations> {
  List<String> postTitles = [
    "가족끼리 경주여행",
    "친구랑 경주",
    "여행가긔",
    "여행코스 괜찮나 봐주실분"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      height: 150,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: postTitles.map((post){
            return Container(
              padding: EdgeInsets.all(5),
              child: Column(children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: grayColor),
                ),
                SizedBox(height: 7),
                Container(
                  alignment: Alignment.center,
                  width: 80,
                  child: Text(post, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.clip),
                )
              ]));
          }).toList(),
        ),
      ),
    );
  }
}
