import 'package:flutter/material.dart';

import '../../common/widget/color.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          isCategorySelected = true;
        });

        AppOverlayController.showAppBarOverlay(
          context,
          category["label"],
              () {
            setState(() {
              isCategorySelected = false;
            });
          },
        );

        _getNearByPlaces(
          _mapCenter.latitude,
          _mapCenter.longitude,
          "POPULARITY",
          category["type"],
        );

        // 카테고리에 따라 스크롤 애니메이션 적용
        if (category["scrollToMin"] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _categoryScrollController.animateTo(
              _categoryScrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }

        if (category["scrollToMax"] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _categoryScrollController.animateTo(
              _categoryScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: lightGrayColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Row(
        children: [
          Icon(
            category["icon"],
            color: blackColor,
            size: 18,
          ),
          SizedBox(width: 5),
          Text(
            category["label"],
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
