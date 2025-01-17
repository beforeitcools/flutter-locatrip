import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/region_select_filter_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostFilter extends StatelessWidget {
  final List<String> orderFilterList;
  final Function(String) orderFilterHandler;
  String selectedOrderFilter;
  // final Map<String, List> regionFilterMapList;
  String selectedRegionFilter;
  final Function(String) regionFilterHandler;
  final Function(String, String) applyFilters;

  PostFilter({
    super.key,
    required this.orderFilterList,
    required this.orderFilterHandler,
    required this.selectedOrderFilter,
    // required this.regionFilterMapList,
    required this.selectedRegionFilter,
    required this.regionFilterHandler,
    required this.applyFilters,
  });

  /*@override
  State<PostFilter> createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {
  late List _orderFilterList;
  late Function _orderFilterHandler;
  late String _selectedOrderFilter;
  late Map _regionFilterMapList;
  late String _selectedRegionFilter;
  late Function(String) _regionFilterHandler;
  late Function(String, String) _applyFilters;

  @override
  void initState() {
    super.initState();
    _orderFilterList = widget.orderFilterList;
    _orderFilterHandler = widget.orderFilterHandler;
    _selectedOrderFilter = widget.selectedOrderFilter;
    _selectedRegionFilter = widget.selectedRegionFilter;
    _regionFilterHandler = widget.regionFilterHandler;
    _applyFilters = widget.applyFilters;
  }*/

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /*TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegionSelectFilterScreen(
                        applyFilters: _applyFilters,
                        regionFilterHandler: _regionFilterHandler,
                        selectedRegionFilter: _selectedRegionFilter,
                        selectedOrderFilter: _selectedOrderFilter,
                      )),
            );
          },
          label: Text(
            _selectedRegionFilter,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          icon: Icon(Icons.filter_alt_outlined),
          style: TextButton.styleFrom(
            minimumSize: Size(83, 35),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),*/
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
