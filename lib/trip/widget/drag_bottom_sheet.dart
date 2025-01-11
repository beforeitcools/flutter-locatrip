import 'package:flutter/material.dart';

import 'day_widget.dart';

class DragBottomSheet extends StatefulWidget {
  final List<String> dropDownDay;
  final Map<String, dynamic> tripInfo;
  final double animatedPositionedOffset;
  final double containerHeight;
  final ScrollController singleScrollController;
  // final Map<int, List<Map<String, dynamic>>> groupedTripDayAllList;

  const DragBottomSheet(
      {super.key,
      required this.dropDownDay,
      required this.tripInfo,
      required this.animatedPositionedOffset,
      required this.containerHeight,
      required this.singleScrollController,
      required this.groupedTripDayAllList});

  @override
  State<DragBottomSheet> createState() => _DragBottomSheetState();
}

class _DragBottomSheetState extends State<DragBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {}; // 각 DayWidget의 key 저장

  late List<String> _dropDownDay;
  late Map<String, dynamic> _tripInfo;

  bool isExpanded = false;

  // double _animatedPositionedOffset = 0;
  late double _containerHeight;
  late double _animatedPositionedOffset;
  late double _expandedHeight;
  late double _collapsedHeight;
  late ScrollController _singleScrollController;
  bool _isExpanded = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _dropDownDay = widget.dropDownDay;
    _tripInfo = widget.tripInfo;
    _containerHeight = widget.containerHeight;
    _singleScrollController = widget.singleScrollController;
    _animatedPositionedOffset = widget.animatedPositionedOffset;

    // 각 아이템에 GlobalKey 부여
    for (int i = 0; i < _dropDownDay.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final screenHeight = MediaQuery.of(context).size.height;
        _expandedHeight = (screenHeight - 450) + 198; // 겹친값 62
        _collapsedHeight = screenHeight - 450;
      });
    });

    _singleScrollController.addListener(() {
      setState(() {
        _animatedPositionedOffset = _singleScrollController.offset;
      });
    });
  }

  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
      _containerHeight = _isExpanded ? _expandedHeight : _collapsedHeight;
    });
  }

  // 날짜 선택 시 해당 위치로 스크롤
  void _scrollToSelectedItem(int index) {
    setState(() {
      _selectedIndex = index;
      print('__selectedIndex $_selectedIndex');
    });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      bottom: 0,
      left: 0,
      right: 0,
      height: _containerHeight + _animatedPositionedOffset,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          // 드래그에 따른 높이 변경
          setState(() {
            _containerHeight -= details.delta.dy;
            if (_containerHeight > _expandedHeight) {
              _containerHeight = _expandedHeight;
            } else if (_containerHeight < _collapsedHeight) {
              _containerHeight = _collapsedHeight;
            }
          });
        },
        onVerticalDragEnd: (details) {
          // 드래그 종료 시 높이 고정
          if (_containerHeight > (_expandedHeight + _collapsedHeight) / 2) {
            setState(() {
              _isExpanded = true;
              _containerHeight = _expandedHeight;
            });
          } else {
            setState(() {
              _isExpanded = false;
              _containerHeight = _collapsedHeight;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              // 핸들러
              GestureDetector(
                  onTap: _toggleContainer,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 20, horizontal: (screenWidth - 40) / 2),
                    child: Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  itemCount: _dropDownDay.length,
                  itemBuilder: (context, index) {
                    return Container(
                      key: _itemKeys[index],
                      child: DayWidget(
                          selectedItem: _dropDownDay[index],
                          dropDownDay: _dropDownDay,
                          index: index,
                          onDateSelected: _scrollToSelectedItem,
                          selectedIndex: _selectedIndex,
                          tripInfo: _tripInfo,
                          groupedTripDayAllList: widget.groupedTripDayAllList),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
