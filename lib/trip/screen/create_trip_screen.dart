import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_locatrip/trip/model/calendar_model.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';
import 'package:flutter_locatrip/trip/screen/trip_view_screen.dart';

import '../../common/widget/color.dart';
import '../model/date_range_model.dart';

class CreateTripScreen extends StatefulWidget {
  final List<Map<String, String>> selectedRegions;
  final String defaultImageUrl;

  const CreateTripScreen(
      {super.key,
      required this.selectedRegions,
      required this.defaultImageUrl});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  late List<Map<String, String>> selectedRegions;
  late String defaultImageUrl;

  TextEditingController _titleInputController = TextEditingController();

  DateRangeModel _dateRangeModel = DateRangeModel();
  bool isCreated = false;

  TripModel _tripModel = TripModel();

  void _openDatePicker() async {
    DateRangeModel? newRange =
        await CalendarPickerModal.showDateRangePickerModal(
      context: context,
      initialRange: _dateRangeModel,
    );

    if (newRange != null) {
      setState(() {
        _dateRangeModel.startDate = newRange.startDate;
        _dateRangeModel.endDate =
            newRange.endDate ?? newRange.startDate; // 종료 날짜 없으면 시작 날짜로 설정

        if (_titleInputController.text.isNotEmpty) {
          isCreated = true;
        }
      });
    }
  }

  void _insertTrip() async {
    List<String> selectedRegionList = [];
    for (var item in selectedRegions) {
      selectedRegionList.add(item["name"].toString());
    }

    String startDateString = _dateRangeModel.startDate != null
        ? _dateRangeModel.startDate!.toIso8601String()
        : "";

    String endDateString = _dateRangeModel.endDate != null
        ? _dateRangeModel.endDate!.toIso8601String()
        : "";

    Map<String, dynamic> tripData = {
      // 임시데이터 - 유저아이디 실제로 받아와야함!!
      "userId": 1,
      "title": _titleInputController.text.toString(),
      "startDate": startDateString,
      "endDate": endDateString,
      "regions": selectedRegionList
    };

    try {
      String result = await _tripModel.insertTrip(tripData);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    } catch (e) {
      print("에러메시지 : $e");
      /*ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error : $e')));*/
    }
  }

  @override
  void initState() {
    super.initState();
    selectedRegions = widget.selectedRegions;
    defaultImageUrl = widget.defaultImageUrl;

    Future.delayed(Duration.zero, () {
      _openDatePicker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightGrayColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: lightGrayColor,
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(16, 25, 16, 0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
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
                                        borderRadius: BorderRadius.circular(12),
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
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: lightGrayColor,
                                      width: 1.0,
                                      style: BorderStyle.solid))),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () {
                                _openDatePicker();
                              },
                              child: Text(
                                  _dateRangeModel.startDate == null
                                      ? '날짜를 선택해주세요'
                                      : _dateRangeModel.startDate ==
                                              _dateRangeModel.endDate
                                          ? '${_dateRangeModel.startDate!.toString().split(' ')[0] ?? '미설정'}'
                                          : '${_dateRangeModel.startDate!.toString().split(' ')[0]} ~ '
                                              '${_dateRangeModel.endDate?.toString().split(' ')[0] ?? '미설정'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600))),
                        ),
                        Container(
                          // 선
                          width: double.infinity,
                          height: 1,
                          color: lightGrayColor,
                        ),
                        TextField(
                          controller: _titleInputController,
                          onChanged: (value) {
                            setState(() {
                              if (value.isNotEmpty &&
                                  _dateRangeModel.startDate != null) {
                                isCreated = true;
                              } else {
                                isCreated = false;
                              }

                              print(value.isNotEmpty);
                              print(_dateRangeModel.startDate);
                            });
                          },
                          maxLength: 20,
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
                            contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      onPressed: isCreated
                          ? () {
                              _insertTrip();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripViewScreen(
                                        /*selectedRegions: selectedRegions,
                                      dateRangeModel: _dateRangeModel,
                                      title: _titleInputController.text,*/
                                        ),
                                    fullscreenDialog: true,
                                  ));
                            }
                          : null,
                      style: TextButton.styleFrom(
                        minimumSize: Size(100, 56), // 최소 높이 설정
                        backgroundColor:
                            !isCreated ? lightGrayColor : pointBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 둥근 테두리 설정
                        ),
                        side: BorderSide(
                          color: isCreated ? Colors.transparent : Colors.white,
                          width: 1,
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
