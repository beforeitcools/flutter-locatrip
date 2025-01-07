import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ShortageDialog extends StatelessWidget {
  const ShortageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.all(24),
        title: Text("게시글 작성 안내", style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20)),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("게시글을 작성하려면 3개 이상의 장소가 등록된 여행 일정이 있어야 합니다."),
              Text("장소가 3개 이상 추가된 여행일정이 없습니다."),
              Text("지금 여행일정을 등록하시겠습니까?")
            ]),
        actions: [
          SizedBox(height: 60,
            child: TextButton(
                onPressed: (){Navigator.pop(context);},
                child: Text("취소", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: grayColor)))),
          SizedBox(height: 60,
              child: TextButton(
                  onPressed: (){Navigator.pop(context); /*TODO: 일정 등록 페이지로 이동*/},
                  child: Text("확인", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: pointBlueColor)))),
        ],
    );
  }
}
