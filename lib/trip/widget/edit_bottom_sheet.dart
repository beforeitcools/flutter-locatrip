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
          TextButton(onPressed: () {}, child: Text("여행도시 추가 및 편집")),
          TextButton(onPressed: () {}, child: Text("여행제목 수정")),
          TextButton(onPressed: () {}, child: Text("여행 나가기")),
        ],
      ),
    );
  }
}
