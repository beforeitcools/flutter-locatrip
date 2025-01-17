import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/region_select_filter_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostFilter extends StatelessWidget {
  final List<String> orderFilterList;
  final Function(String) orderFilterHandler;
  String selectedOrderFilter;
  String selectedRegionFilter;
  final Function(String) regionFilterHandler;
  final Function(String, String) applyFilters;

  PostFilter({
    super.key,
    required this.orderFilterList,
    required this.orderFilterHandler,
    required this.selectedOrderFilter,
    required this.selectedRegionFilter,
    required this.regionFilterHandler,
    required this.applyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          // 지역 선택 스크린으로 이동
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegionSelectFilterScreen(
                        applyFilters: applyFilters,
                        regionFilterHandler: regionFilterHandler,
                        selectedRegionFilter: selectedRegionFilter,
                        selectedOrderFilter: selectedOrderFilter,
                      )),
            );
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(
                  border: Border.all(color: lightGrayColor),
                  borderRadius: BorderRadius.circular(6)),
              child: Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Text(selectedRegionFilter,
                        style: Theme.of(context).textTheme.titleSmall),
                    Icon(Icons.filter_alt_outlined),
                  ],
                ),
              )),
        ),
        SizedBox(
          width: 16,
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            border: Border.all(color: lightGrayColor),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Color.fromARGB(50, 43, 192, 228),
              highlightColor: Color.fromARGB(30, 43, 192, 228),
            ),
            child: Material(
              color: Colors.transparent,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOrderFilter,
                  elevation: 1,
                  dropdownColor: Colors.white,
                  items: orderFilterList
                      .map((order) => DropdownMenuItem<String>(
                          value: order,
                          child: Text(order,
                              style: Theme.of(context).textTheme.titleSmall)))
                      .toList(),
                  onChanged: (value) {
                    orderFilterHandler(value!);
                    applyFilters(selectedRegionFilter, selectedOrderFilter);
                    /*setState(() {
                      _selectedOrderFilter = value!;
                    });*/
                  },
                  icon: Icon(Icons.keyboard_arrow_down_outlined),
                  iconSize: 24,
                  borderRadius: BorderRadius.circular(6),
                  style: Theme.of(context).textTheme.titleSmall,
                  alignment: AlignmentDirectional.topStart,
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
