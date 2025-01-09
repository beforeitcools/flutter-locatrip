import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostFilter extends StatefulWidget {
  const PostFilter({super.key});

  @override
  State<PostFilter> createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {

  final _filters = ["최신순", "첨삭순"];
  String _selectedFilter = "";


  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedFilter = _filters[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        decoration: BoxDecoration(
            border: Border.all(color: lightGrayColor),
            borderRadius: BorderRadius.circular(6)
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: DropdownButton(
            value: _selectedFilter,
            elevation: 0,
            items: _filters.map((select)=>DropdownMenuItem(
                child: Container(
                    child: Text(select, style: Theme.of(context).textTheme.labelMedium)),
                value: select)).toList(),
            onChanged: (value){
              setState(() {
                _selectedFilter = value!;
              });},
            underline: Container(),
            icon: Icon(Icons.arrow_drop_down),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: blackColor),
            dropdownColor: Colors.white,
            alignment: Alignment.center,
          ),
        )
    );
  }
}
