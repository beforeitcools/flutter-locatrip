import 'dart:async';

import 'package:flutter/material.dart';

import 'day_widget.dart';

class DragBottomSheet extends StatefulWidget {
  final List<String> dropDownDay;
  final Map<String, dynamic> tripInfo;
  final double animatedPositionedOffset;
  final double containerHeight;
  final ScrollController singleScrollController;
  final Map<int, List<Map<String, dynamic>>> groupedTripDayAllList;
  final ScrollController bottomScrollController;
  final List colors;
  final Future<void> Function(List<Map<String, dynamic>>, int)
      updateMarkersAndPolylines;

  const DragBottomSheet(
      {super.key,
      required this.dropDownDay,
      required this.tripInfo,
      required this.animatedPositionedOffset,
      required this.containerHeight,
      required this.singleScrollController,
      required this.groupedTripDayAllList,
      required this.bottomScrollController,
      required this.colors,
      required this.updateMarkersAndPolylines
      //required this.addCustomTextMarker
      });

  @override
  State<DragBottomSheet> createState() => _DragBottomSheetState();
}

class _DragBottomSheetState extends State<DragBottomSheet> {
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
  late ScrollController _scrollController; // 바텀시트 내부
  late bool _isExpanded = false;
  int _selectedIndex = 0;
  late Map<int, List<Map<String, dynamic>>> _groupedTripDayAllList;
  late List<int> sortedKeys;

  final Map<int, double> itemOffsets = {};

  @override
  void initState() {
    super.initState();
    _dropDownDay = widget.dropDownDay;
    _tripInfo = widget.tripInfo;
    _containerHeight = widget.containerHeight;
    _singleScrollController = widget.singleScrollController;
    _animatedPositionedOffset = widget.animatedPositionedOffset;
    _groupedTripDayAllList = widget.groupedTripDayAllList;

    _scrollController = widget.bottomScrollController;
    //_addCustomTextMarker = widget.addCustomTextMarker;

    // 각 아이템에 GlobalKey 부여
    for (int i = 0; i < _dropDownDay.length; i++) {
      _itemKeys[i] = GlobalKey();
    }

    _singleScrollController.addListener(() {
      setState(() {
        _animatedPositionedOffset = _singleScrollController.offset;
      });
    });

    /*// 프레임 렌더링 이후 높이를 계산
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _dropDownDay.length; i++) {
        if (_itemKeys[i]?.currentContext == null) {
          final RenderBox renderBox =
              _itemKeys[i]?.currentContext!.findRenderObject() as RenderBox;
          renderBox.size = (MediaQuery.of(context).size.width, 104) as Size;
        }
      }
    });*/

    // _initializeScrollListener();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant DragBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상위 위젯에서 데이터가 변경된 후 이를 처리
    if (widget.groupedTripDayAllList != oldWidget.groupedTripDayAllList) {
      setState(() {
        _groupedTripDayAllList = widget.groupedTripDayAllList;
      });
    }
  }

  @override
  void dispose() {
    _singleScrollController.dispose();

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
    });
    double offset = 0;
    for (int i = 0; i < index; i++) {
      final key = _itemKeys[i];
      final context = key?.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        offset += box.size.height; // 각 DayWidget의 높이를 누적
        print('offset $offset');
      }
    }

    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 스크롤에 따라 지나고 있는 DayWidget 추적
  void _onScroll() {
    double totalOffset = _scrollController.offset;
    double accumulatedOffset = 0;
    List<Map<String, dynamic>> tripDayAllList =
        _groupedTripDayAllList.values.expand((list) => list).toList();

    for (int i = 0; i < _itemKeys.length; i++) {
      accumulatedOffset += itemOffsets[i] ?? 104.0; // 기본값 104.0으로 설정
      print('accumulatedOffest $accumulatedOffset');

      if (accumulatedOffset > totalOffset) {
        // 지나고 있는 DayWidget을 찾으면
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i; // 현재 지나고 있는 DayWidget 인덱스 설정
          });
          widget.updateMarkersAndPolylines(tripDayAllList, _selectedIndex);
        }
        break; // 첫 번째로 지나고 있는 DayWidget을 찾으면 종료
      }
    }
  }

  // ListView에서 아이템의 높이를 전달받아 itemOffsets에 저장
  void _updateItemHeight(int index, double height) {
    setState(() {
      itemOffsets[index] = height; // 해당 index의 높이를 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
              _dropDownDay.length == _groupedTripDayAllList.length
                  ? Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        itemCount: _dropDownDay.length,
                        itemBuilder: (context, index) {
                          int key =
                              _groupedTripDayAllList.keys.elementAt(index);
                          List<Map<String, dynamic>> dayPlaceList =
                              _groupedTripDayAllList[key] ?? [];

                          return Container(
                            key: _itemKeys[index],
                            child: DayWidget(
                              selectedItem: _dropDownDay[index],
                              dropDownDay: _dropDownDay,
                              index: index,
                              onHeightCalculated: (height) =>
                                  _updateItemHeight(index, height),
                              onDateSelected: _scrollToSelectedItem,
                              selectedIndex: _selectedIndex,
                              tripInfo: _tripInfo,
                              dayPlaceList: dayPlaceList,
                              colors: widget.colors,
                              scrollController: _scrollController,
                              updateMarkersAndPolylines:
                                  widget.updateMarkersAndPolylines,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
