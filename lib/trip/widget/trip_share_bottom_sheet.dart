import 'package:flutter/material.dart';

import '../../common/widget/color.dart';

class TripShareBottomSheet extends StatefulWidget {
  const TripShareBottomSheet({super.key});

  @override
  State<TripShareBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<TripShareBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "일정 링크 공유하기 (보기전용)",
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: grayColor, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xfffee500),
                      image: DecorationImage(
                          image: AssetImage("assets/kakao_logo.png"),
                          scale: 1.8)),
                ),
                Text(
                  "카카오톡으로 링크 보내기",
                  style: Theme.of(context).textTheme.labelSmall,
                )
              ])),
          TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: pointBlueColor),
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.link,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "링크 복사하기",
                  style: Theme.of(context).textTheme.labelSmall,
                )
              ])),
          Container(
            width: double.infinity,
            height: 1,
            color: lightGrayColor,
            margin: EdgeInsets.only(top: 6, bottom: 10),
          ),
          Text(
            "· 위 링크만 보유하면 누구나 여행 일정을 확인할 수 있습니다.",
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: grayColor, fontSize: 10),
          ),
          Text("· 여행 일정 내에 개인정보가 있는 경우 링크 공유에 유의해주시기 바랍니다.",
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: grayColor, fontSize: 10))
        ],
      ),
    );
  }
}
