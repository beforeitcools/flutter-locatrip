import 'package:flutter/material.dart';

import '../../common/widget/color.dart';

class SortBottomSheet extends StatefulWidget {
  final Function(String) sortTrips;
  const SortBottomSheet({super.key, required this.sortTrips});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "정렬",
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: grayColor, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () {
                widget.sortTrips("startDate");
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "날짜순",
                style: Theme.of(context).textTheme.labelMedium,
              )),
          TextButton(
              onPressed: () {
                widget.sortTrips("title");
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "제목순",
                style: Theme.of(context).textTheme.labelMedium,
              )),
        ],
      ),
    );
    ;
  }
}
