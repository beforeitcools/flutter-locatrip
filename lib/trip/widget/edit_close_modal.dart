import 'package:flutter/material.dart';

import '../../common/widget/color.dart';

class EditCloseModal extends StatelessWidget {
  const EditCloseModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(20),
      actionsPadding: EdgeInsets.all(5),
      content: Text(
        "일정 편집을 취소하시겠습니까? 지금까지 편집한 일정이 사라집니다.",
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("취소",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: grayColor)),
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("확인",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: pointBlueColor, fontWeight: FontWeight.w500))),
      ],
    );
  }
}
