import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class CategoryTabMenuWidget extends StatefulWidget {
  Function(int) categoryOnTabHandler;
  int selectedIndex;
  List<String> categories;

  CategoryTabMenuWidget({
    super.key,
    required this.categoryOnTabHandler,
    required this.selectedIndex,
    required this.categories,
  });

  @override
  State<CategoryTabMenuWidget> createState() => _CategoryTabMenuWidgetState();
}

class _CategoryTabMenuWidgetState extends State<CategoryTabMenuWidget> {
  late List _categories;
  late Function _categoryOnTabHandler;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _categories = widget.categories;
    _categoryOnTabHandler = widget.categoryOnTabHandler;
    _selectedIndex = widget.selectedIndex;
  }

  Widget _categoryTabCreator(int index) {
    // 해당 category의 index 와 선택된 index가 동일한지로 선택됨 여부 판단
    bool isSelected = index == _selectedIndex;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            _categoryOnTabHandler(index);
          },
          splashColor: Color.fromARGB(50, 43, 192, 228),
          highlightColor: Color.fromARGB(30, 43, 192, 228),
          child: Container(
            alignment: Alignment.center,
            height: 56,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? pointBlueColor : grayColor,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
            ),
            child: Text(
              _categories[index],
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansKR',
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _categories.length,
        (index) => _categoryTabCreator(index),
      ),
    );
  }
}
