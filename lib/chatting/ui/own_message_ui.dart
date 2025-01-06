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
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 50),
              Text("$onlyTime", style: Theme.of(context).textTheme.labelSmall!.copyWith(color: grayColor),),
              ConstrainedBox(constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 55),
                child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: pointBlueColor,
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white))
                    )))
            ],
          ),
        ));
  }
}
