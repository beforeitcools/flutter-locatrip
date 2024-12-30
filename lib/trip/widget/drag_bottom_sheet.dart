import 'package:flutter/material.dart';

class DragBottomSheet extends StatefulWidget {
  const DragBottomSheet({super.key});

  @override
  State<DragBottomSheet> createState() => _DragBottomSheetState();
}

class _DragBottomSheetState extends State<DragBottomSheet> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.43, // 초기 높이 비율
      minChildSize: 0.43, // 최소 높이 비율
      maxChildSize: 0.77, // 최대 높이 비율
      controller: sheetController,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: ListView.builder(
            controller: scrollController,
            itemCount: 50, // 예제 아이템 수
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
              );
            },
          ),
        );
      },
    );
  }
}
