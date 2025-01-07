import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class DateBottomSheet extends StatefulWidget {
  final List<String> dropDownDayList;
  final int index;
  final Function(int) onItemSelected;
  const DateBottomSheet(
      {super.key,
      required this.dropDownDayList,
      required this.index,
      required this.onItemSelected});

  @override
  State<DateBottomSheet> createState() => _DateBottomSheetState();
}

class _DateBottomSheetState extends State<DateBottomSheet> {
  late List<String> _dropDownDay;
  late int _index;

  @override
  void initState() {
    super.initState();

    _dropDownDay = widget.dropDownDayList;
    _index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Text(
              '날짜 선택',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: grayColor, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            /*children: _dropDownDay.map((String item) {
              return SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () {
                        widget.onItemSelected(_index);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          minimumSize: Size(0, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                      child: item != _dropDownDay[_index]
                          ? Text(
                              item,
                              style: Theme.of(context).textTheme.labelSmall,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: pointBlueColor,
                                          fontWeight: FontWeight.w600),
                                ),
                                Icon(Icons.check)
                              ],
                            )));
            }).toList(),*/
            children: _dropDownDay.asMap().entries.map((entry) {
              int idx = entry.key;
              String item = entry.value;
              return SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    widget.onItemSelected(idx); // 선택된 인덱스 반환
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    minimumSize: Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: item != _dropDownDay[_index]
                      ? Text(
                          item,
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: pointBlueColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Icon(Icons.check),
                          ],
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
