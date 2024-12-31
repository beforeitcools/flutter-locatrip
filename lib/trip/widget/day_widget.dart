/*
import 'package:flutter/material.dart';

class DayWidget extends StatefulWidget {
  const DayWidget({super.key});

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("day$num"),
            DropdownButton(items: _dayList.map((dynamic day) {
              return DropdownMenuItem(child: Text(day.toString()), value: day,),
            }), onChanged: (){}),
            TextButton(onPressed: (){}, child: Text("편집")),
          ],
        ),
        Container(
          child: ListView.builder(
            itemBuilder: (context){
              return ListTile(
                leading: Text(),
              );
            }
          ),
        ),
        Row(
          children: [
            TextButton(onPressed: (){}, child: Text("장소추가")),
            TextButton(onPressed: (){}, child: Text("메모추가")),
          ],
        ),
      ],
    );
  }
}
*/
