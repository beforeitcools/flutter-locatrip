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
  final void Function(String, List<Map<String, dynamic>>, int) onMarkerTap;
  final bool isEditing;
  final Function(bool) onEditingChange;

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
      required this.updateMarkersAndPolylines,
      required this.onMarkerTap,
      required this.isEditing,
      required this.onEditingChange});

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
  int _selectedIndex2 = 0;
  late Map<int, List<Map<String, dynamic>>> _groupedTripDayAllList;
  late List<int> sortedKeys;

  final Map<int, double> itemOffsets = {};

  final double focusThreshold = 0.0; // 특정 시작점에서 포커스할 오프셋
  int _focusedTileIndex = -1; // 현재 포커스된 ListTile 인덱스

  final Map<int, List<GlobalKey>> _listTileKeys = {};
  final Map<int, List<GlobalKey>> _listTileKeys2 = {};

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

    _scrollController.addListener(_onScroll);
    _scrollController.addListener(_onTileScrolledTo);

    // _initializeKeys();
  }

  @override
  void didUpdateWidget(covariant DragBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상위 위젯에서 데이터가 변경된 후 이를 처리
    if (widget.groupedTripDayAllList != oldWidget.groupedTripDayAllList) {
      setState(() {
        _groupedTripDayAllList = widget.groupedTripDayAllList;
        print('!_groupedTripDayAllList $_groupedTripDayAllList');
        // 모든 날짜에 대해 dayPlaceList에 맞춰 키 업데이트

        _groupedTripDayAllList.forEach((day, dayPlaceList) {
          _updateListTileKeys(day, dayPlaceList);
        });
      });
    }
  }

  @override
  void dispose() {
    _singleScrollController.dispose();

    _scrollController.removeListener(_onScroll);
    _scrollController.removeListener(_onTileScrolledTo);
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
      offset += itemOffsets[i] ?? 104.0;
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
      // print('accumulatedOffest $accumulatedOffset');

      if (accumulatedOffset > totalOffset) {
        // 지나고 있는 DayWidget 을 찾으면
        if (_selectedIndex2 != i) {
          setState(() {
            _selectedIndex2 = i; // 현재 지나고 있는 DayWidget 인덱스 설정
          });
          widget.updateMarkersAndPolylines(tripDayAllList, _selectedIndex2);
        }
        break; // 첫 번째로 지나고 있는 DayWidget 을 찾으면 종료
      }
    }
  }

  // ListView에서 아이템의 높이를 전달받아 itemOffsets에 저장
  void _updateItemHeight(int index, double height) {
    setState(() {
      itemOffsets[index] = height; // 해당 index의 높이를 업데이트
    });
  }

  /*void _scrollToSelectedListItem() {
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }*/

  // ListTile 스크롤
  void _onTileScrolledTo() {
    _listTileKeys.forEach((day, keys) {
      // 날짜 별로 ListTile 키를 가져옴
      for (int index = 0; index < keys.length; index++) {
        final key = keys[index]; // 특정 ListTile 의 GlobalKey
        print('key $key $index');
        if (key != null) {
          // 바텀시트의 RenderBox 가져오기
          final RenderBox? bottomSheetBox =
              context.findRenderObject() as RenderBox?;
          final renderBox =
              key.currentContext?.findRenderObject() as RenderBox?;

          if (renderBox != null && bottomSheetBox != null) {
            // 바텀시트 기준의 Y 좌표 계산
            final double relativeOffset = renderBox
                    .localToGlobal(Offset.zero, ancestor: bottomSheetBox)
                    .dy -
                46; // 드래그 핸들러 높이
            /*  print(
                'Relative Y Offset: $relativeOffset (Day: $day, Index: $index)');

            print('Scroll Offset: ${_scrollController.offset}');
*/
            // 포커스 조건 충족 여부 확인
            if (relativeOffset <= focusThreshold &&
                relativeOffset + renderBox.size.height > focusThreshold) {
              if (_focusedTileIndex != index || _selectedIndex2 != day) {
                setState(() {
                  _focusedTileIndex = index;
                  /*String markerId, List<Map<String, dynamic>> tripDayAllList,
                  int dateIndex*/
                });
                if (_groupedTripDayAllList[day]?[index]["place"] != null) {
                  setState(() {
                    widget.onMarkerTap(
                        _groupedTripDayAllList[day]?[index]["place"].id,
                        _groupedTripDayAllList[day]!,
                        day);
                  });
                }
                // print('Focused on ListTile $index in Day $day');
              }
              return; // 한 번 포커스를 찾으면 중단
            }
          }
        }
      }
    });
    _listTileKeys2.forEach((day, keys) {
      // 날짜 별로 ListTile 키를 가져옴
      for (int index = 0; index < keys.length; index++) {
        final key = keys[index]; // 특정 ListTile 의 GlobalKey
        print('key2 $key $index');
        if (key != null) {
          // 바텀시트의 RenderBox 가져오기
          final RenderBox? bottomSheetBox =
              context.findRenderObject() as RenderBox?;
          final renderBox =
              key.currentContext?.findRenderObject() as RenderBox?;

          if (renderBox != null && bottomSheetBox != null) {
            // 바텀시트 기준의 Y 좌표 계산
            final double relativeOffset = renderBox
                    .localToGlobal(Offset.zero, ancestor: bottomSheetBox)
                    .dy -
                46; // 드래그 핸들러 높이
            /*  print(
                'Relative Y Offset: $relativeOffset (Day: $day, Index: $index)');

            print('Scroll Offset: ${_scrollController.offset}');
*/
            // 포커스 조건 충족 여부 확인
            if (relativeOffset <= focusThreshold &&
                relativeOffset + renderBox.size.height > focusThreshold) {
              if (_focusedTileIndex != index || _selectedIndex2 != day) {
                setState(() {
                  _focusedTileIndex = index;
                  /*String markerId, List<Map<String, dynamic>> tripDayAllList,
                  int dateIndex*/
                });
                if (_groupedTripDayAllList[day]?[index]["place"] != null) {
                  setState(() {
                    widget.onMarkerTap(
                        _groupedTripDayAllList[day]?[index]["place"].id,
                        _groupedTripDayAllList[day]!,
                        day);
                  });
                }
                // print('Focused on ListTile $index in Day $day');
              }
              return; // 한 번 포커스를 찾으면 중단
            }
          }
        }
      }
    });
  }

  void _updateListTileKeys(int day, List<Map<String, dynamic>> dayPlaceList) {
    if (!_listTileKeys.containsKey(day)) {
      _listTileKeys[day] = [];
    }

    final currentLength = _listTileKeys[day]!.length;
    if (dayPlaceList.length > currentLength) {
      // 부족한 키를 추가
      _listTileKeys[day]!.addAll(
        List.generate(
            dayPlaceList.length - currentLength, (index) => GlobalKey()),
      );
    } else if (dayPlaceList.length < currentLength) {
      // 여분의 키를 제거
      _listTileKeys[day] = _listTileKeys[day]!.sublist(0, dayPlaceList.length);
    }

    if (!_listTileKeys2.containsKey(day)) {
      _listTileKeys2[day] = [];
    }

    final currentLength2 = _listTileKeys2[day]!.length;
    if (dayPlaceList.length > currentLength2) {
      // 부족한 키를 추가
      _listTileKeys2[day]!.addAll(
        List.generate(
          dayPlaceList.length - currentLength2,
          (index) => GlobalKey(),
        ),
      );
    } else if (dayPlaceList.length < currentLength2) {
      // 여분의 키를 제거
      _listTileKeys2[day] =
          _listTileKeys2[day]!.sublist(0, dayPlaceList.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    _groupedTripDayAllList.forEach((day, dayPlaceList) {
      _updateListTileKeys(day, dayPlaceList);
    });

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
                      child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        // 리스트가 스크롤 가능한지 여부를 확인
                        if (notification is OverscrollNotification &&
                            notification.overscroll < 0) {
                          // 부모로 스크롤 전달
                          _singleScrollController.jumpTo(
                            _singleScrollController.offset +
                                notification.overscroll,
                          );
                        } else if (notification is ScrollEndNotification) {
                          // 자식 스크롤이 끝났는지 확인
                          if (_scrollController.position.extentAfter == 0) {
                            _singleScrollController.animateTo(
                              _singleScrollController.offset + 50, // 부모 스크롤 이동
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        }
                        return true;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        // physics: BouncingScrollPhysics(),
                        itemCount: _dropDownDay.length,
                        itemBuilder: (context, index) {
                          int key =
                              _groupedTripDayAllList.keys.elementAt(index);
                          List<Map<String, dynamic>> dayPlaceList =
                              _groupedTripDayAllList[key] ?? [];
                          int key2 = _listTileKeys.keys.elementAt(index);
                          List<GlobalKey> listTilekey =
                              _listTileKeys[key2] ?? [];
                          int key3 = _listTileKeys2.keys.elementAt(index);
                          List<GlobalKey> listTilekey2 =
                              _listTileKeys2[key3] ?? [];

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
                              listTileKeys: listTilekey,
                              listTileKeys2: listTilekey2,
                              focusedTileIndex: _focusedTileIndex,
                              isEditing: widget.isEditing,
                              onEditingChange: widget.onEditingChange,
                            ),
                          );
                        },
                      ),
                    ))
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
