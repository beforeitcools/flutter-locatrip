import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class OwnMessageUi extends StatelessWidget {
  String text;
  String time;
  OwnMessageUi({super.key, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    String onlyTime = '${time.split('T')[1].split(':')[0]}:${time.split(':')[1]}';

    return Align(alignment: Alignment.centerRight,
      child: ConstrainedBox(constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 55),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: pointBlueColor,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6.5),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
                child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white))),
              Positioned(
                bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(onlyTime),
                      Text("1")],
              ))
            ],
          ),
        ),));
  }
}
