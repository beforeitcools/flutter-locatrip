import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

class CalendarModel {
  DateTime? startDate;
  DateTime? endDate;

  CalendarModel({this.startDate, this.endDate});

  String getFormattedRange() {
    if (startDate != null && endDate != null) {
      return '${startDate!.toLocal()} - ${endDate!.toLocal()}';
    } else {
      return 'No date range selected';
    }
  }

  // 날짜 범위 선택 메서드
  Future<void> selectDateRange(BuildContext context) async {
    final List<DateTime>? selectedDates = await showDialog<List<DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          // Material 위젯만 추가
          child: CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now().add(Duration(days: 365)),
            ),
            value: startDate != null && endDate != null
                ? [startDate!, endDate!] // value 파라미터에 선택된 날짜 범위를 전달
                : [],
            onValueChanged: (dates) {
              if (dates != null && dates.isNotEmpty && dates.length == 2) {
                Navigator.of(context).pop(dates); // 선택된 날짜를 반환
              }
            },
          ),
        );
      },
    );

    if (selectedDates != null && selectedDates.length == 2) {
      startDate = selectedDates[0];
      endDate = selectedDates[1];
    }
  }
}
