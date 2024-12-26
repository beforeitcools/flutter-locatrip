import 'package:flutter/material.dart';

import 'package:flutter_locatrip/trip/model/calendar_model.dart';

import '../../common/widget/color.dart';

class CreateTripScreen extends StatefulWidget {
  final List<Map<String, String>> selectedRegions;
  final String defaultImageUrl;
  final bool isAbled;
  const CreateTripScreen(
      {super.key,
      required this.selectedRegions,
      required this.defaultImageUrl,
      required this.isAbled});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final CalendarModel _calendarModel = CalendarModel();
  // DateTimeRange? selectedDateRange;
  late List<Map<String, String>> selectedRegions;
  late String defaultImageUrl;
  late bool isAbled;

  TextEditingController _titleInputController = TextEditingController();
  Future<void> _selectDateRange() async {
    await _calendarModel.selectDateRange(context); // 날짜 범위 선택
    setState(() {}); // 날짜 범위가 변경되었을 때 UI 업데이트
  }

  @override
  void initState() {
    super.initState();
    selectedRegions = widget.selectedRegions;
    defaultImageUrl = widget.defaultImageUrl;
    isAbled = widget.isAbled;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _selectDateRange(); // 날짜 범위 선택
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(16, 25, 16, 0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ...selectedRegions.map((region) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 20, 20),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            12), // 이미지 둥글게
                                        child: Image.asset(
                                          region["imageUrl"].toString() ??
                                              defaultImageUrl,
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              defaultImageUrl,
                                              width: 50,
                                              height: 50,
                                            );
                                          },
                                        ),
                                      ),
                                      Text(
                                        region["name"].toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: grayColor),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        Container(
                          // 선
                          width: double.infinity,
                          height: 1,
                          color: lightGrayColor,
                        ),
                        TextField(
                          controller: _titleInputController,
                          decoration: InputDecoration(
                            hintText: "여행 제목",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: grayColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 0,
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 0, // 포커스 시 하단 밑줄 제거
                                color: Colors.transparent,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ]),
                ),
                SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: _selectDateRange,
                      style: TextButton.styleFrom(
                        minimumSize: Size(100, 56), // 최소 높이 설정
                        backgroundColor:
                            !isAbled ? lightGrayColor : pointBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 둥근 테두리 설정
                        ),
                      ),
                      child: Text(
                        "일정 생성",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      )),
                ),
              ],
            )));
  }
}
