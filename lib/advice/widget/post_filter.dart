import 'package:flutter/material.dart';

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
    return Padding(padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton(
              value: _selectedFilter,
              items: _filters.map((select)=>DropdownMenuItem(child: Text(select), value: select)).toList(),
              onChanged: (value){
                setState(() {
                  _selectedFilter = value!;
                });
              })
        ],
      ),);
  }
}
