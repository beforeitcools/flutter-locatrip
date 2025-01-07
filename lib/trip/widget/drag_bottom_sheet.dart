import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

import 'day_widget.dart';

class DragBottomSheet extends StatefulWidget {
  final List<String> dropDownDay;
  const DragBottomSheet({super.key, required this.dropDownDay});

  @override
  State<DragBottomSheet> createState() => _DragBottomSheetState();
}

class _DragBottomSheetState extends State<DragBottomSheet> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {}; // 각 DayWidget의 key 저장

  late List<String> _dropDownDay;

  dynamic _selectedItem;

  bool isExpanded = false; // 현재 상태 추적 (최대 or 최소)

  final double maxSize = 0.8;
  final double minSize = 0.45;
  final double tolerance = 0.001; // 부동 소수점 오차 허용 범위

  @override
  void initState() {
    super.initState();
    _dropDownDay = widget.dropDownDay;

    // 각 아이템에 GlobalKey 부여
    for (int i = 0; i < _dropDownDay.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    // DraggableScrollableController 의 상태 변화 감지
    sheetController.addListener(() {
      double currentSize = sheetController.size;
      if ((currentSize - maxSize).abs() < tolerance) {
        setState(() {
          isExpanded = true;
        });
      } else if ((currentSize - minSize).abs() < tolerance) {
        setState(() {
          isExpanded = false;
        });
      }
    });
  }

  // 날짜 선택 시 해당 위치로 스크롤
  void _scrollToSelectedItem(int index) {
    double offset = 0;
    for (int i = 0; i < index; i++) {
      final key = _itemKeys[i];
      final context = key?.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        offset += box.size.height; // 각 DayWidget의 높이를 누적
      }
    }

    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 최대/최소 높이 토글
  void _toggleSheetHeight() {
    if (isExpanded) {
      sheetController.animateTo(
        minSize,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      sheetController.animateTo(
        maxSize,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: minSize, // 초기 높이 비율
      minChildSize: minSize, // 최소 높이 비율
      maxChildSize: maxSize, // 최대 높이 비율
      controller: sheetController,
      snap: true,
      builder: (BuildContext context, scrollController) {
        return Container(
          color: Colors.transparent,
          child: Container(
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
                // 드래그 핸들러
                GestureDetector(
                  onTap: _toggleSheetHeight,
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: grayColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics:
                        BouncingScrollPhysics(), // 리스트 수가 적을 때 스크롤 가능 하도록 !
                    itemCount: _dropDownDay.length,
                    itemBuilder: (context, index) {
                      return Container(
                        key: _itemKeys[index], // 각 위젯에 key 부여
                        child: DayWidget(
                          selectedItem: _dropDownDay[index],
                          dropDownDay: _dropDownDay,
                          index: index,
                          onDateSelected: _scrollToSelectedItem,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
