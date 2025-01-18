import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class SubRegionSelectFilterScreen extends StatefulWidget {
  final Function(String, String) applyFilters;
  final Function(String) regionFilterHandler;
  String selectedRegionFilter;
  String selectedOrderFilter;
  final List subRegionList;
  final String selectedRegion;

  SubRegionSelectFilterScreen({
    super.key,
    required this.applyFilters,
    required this.regionFilterHandler,
    required this.selectedRegionFilter,
    required this.selectedOrderFilter,
    required this.subRegionList,
    required this.selectedRegion,
  });

  @override
  State<SubRegionSelectFilterScreen> createState() =>
      _SubRegionSelectFilterScreenState();
}

class _SubRegionSelectFilterScreenState
    extends State<SubRegionSelectFilterScreen> {
  late Function(String, String) _applyFilters;
  late Function(String) _regionFilterHandler;
  late String _selectedRegionFilter;
  late String _selectedOrderFilter;
  late List _subRegionList;
  late String _selectedRegion;

  @override
  void initState() {
    super.initState();
    _applyFilters = widget.applyFilters;
    _regionFilterHandler = widget.regionFilterHandler;
    _selectedRegionFilter = widget.selectedRegionFilter;
    _selectedOrderFilter = widget.selectedOrderFilter;
    _subRegionList = widget.subRegionList;
    _selectedRegion = widget.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedRegion,
            style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3, // Adjust the height of buttons
          ),
          itemCount: _subRegionList.length,
          itemBuilder: (context, index) {
            final region = _subRegionList[index];
            final bool isSelected = _selectedRegionFilter == region;

            return ElevatedButton(
              onPressed: () {
                _regionFilterHandler(region);
                _applyFilters(region, _selectedOrderFilter);
                setState(() {
                  _selectedRegionFilter = region;
                });
                // 시는 navigator.pop 도는 subregion_select_filter_screen 으로
                // length 로 가능할지도

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? pointBlueColor : Colors.white,
                side: BorderSide(
                  color: grayColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isSelected ? 2 : 0,
              ),
              child: Text(
                region,
                style: Theme.of(context).textTheme.titleMedium,
                /*style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),*/
              ),
            );
          },
        ),
      ),
    );
  }
}
