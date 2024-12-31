import 'package:flutter/material.dart';

class DragBottomSheet extends StatefulWidget {
  const DragBottomSheet({super.key});

  @override
  State<DragBottomSheet> createState() => _DragBottomSheetState();
}

class _DragBottomSheetState extends State<DragBottomSheet> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  // List<Widget> dayList = [
  //   DayWidget(),
  // ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.43, // 초기 높이 비율
      minChildSize: 0.43, // 최소 높이 비율
      maxChildSize: 0.77, // 최대 높이 비율
      snap: true,
      controller: sheetController,
      builder: (BuildContext context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("Item $index"),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
*/
