import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

import 'date_range_model.dart';

// 캘린더 모달
class CalendarPickerModal {
  static DateTime today = DateTime.now(); // 오늘 날짜
  static int currentYear = today.year;

  static Future<DateRangeModel?> showDateRangePickerModal({
    required BuildContext context,
    required DateRangeModel initialRange,
  }) async {
    double calendarWidth = MediaQuery.of(context).size.width - 32;
    List<DateTime?>? results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        selectedDayHighlightColor: pointBlueColor,
        selectedDayTextStyle: TextStyle(color: Colors.white),
        firstDate: today,
        lastDate: DateTime(currentYear + 5),
        rangeBidirectional: true,
        centerAlignModePicker: true,
        daySplashColor: Colors.white,
        cancelButton: Text(
          "취소",
          style: TextStyle(color: grayColor),
        ),
        okButton: Text(
          "확인",
          style: TextStyle(color: pointBlueColor, fontWeight: FontWeight.w600),
        ),
      ),
      dialogSize: Size(calendarWidth, 400),
      borderRadius: BorderRadius.circular(16),
      value: [initialRange.startDate, initialRange.endDate],
      dialogBackgroundColor: Colors.white,
    );

    if (results != null) {
      return DateRangeModel(
        startDate: results.isNotEmpty ? results[0] : null,
        endDate: results.length > 1 ? results[1] : results[0],
      );
    }
    return null;
  }
}
