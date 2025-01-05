import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class NoResult extends StatelessWidget {
  const NoResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "검색 결과가 없습니다.",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            height: 10,
          ),
          Text("정확한 도시 이름을 입력해보세요.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: grayColor)),
          Text("단어가 정확한지 확인해보세요.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: grayColor))
        ],
      ),
    );
  }
}
