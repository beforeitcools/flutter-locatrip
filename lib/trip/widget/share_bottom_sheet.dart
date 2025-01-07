import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class DateBottomSheet extends StatefulWidget {
  const DateBottomSheet({super.key});

  @override
  State<DateBottomSheet> createState() => _DateBottomSheetState();
}

class _DateBottomSheetState extends State<DateBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '날짜 선택',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: grayColor, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffFEE500)),
                child: Image.asset(
                  "assets/kakao_logo.png",
                  width: 14,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0)),
                child: Text(
                  '카카오톡 링크 보내기',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ))
            ],
          ),
          /*    onTap: () {
                 // BottomSheet 닫기
              },*/

          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: pointBlueColor),
                child: Icon(
                  Icons.link_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0)),
                child: Text(
                  '링크 복사하기',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ))
            ],
          ),
          /* onTap: () {
              Navigator.pop(context); // BottomSheet 닫기
            },*/
        ],
      ),
    );
  }
}
