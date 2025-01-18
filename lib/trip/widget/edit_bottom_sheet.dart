import 'package:flutter/material.dart';

import '../../common/widget/color.dart';

class EditBottomSheet extends StatefulWidget {
  const EditBottomSheet({super.key});

  @override
  State<EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<EditBottomSheet> {
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
            "편집",
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
              child: Text(
                "여행도시 추가 및 편집",
                style: Theme.of(context).textTheme.labelSmall,
              )),
          TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "여행제목 수정",
                style: Theme.of(context).textTheme.labelSmall,
              )),
          TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "여행 나가기",
                style: Theme.of(context).textTheme.labelSmall,
              )),
        ],
      ),
    );
  }
}
