import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ReplyMessageUi extends StatelessWidget {
  String text;
  String time;
  bool isRead = true;

  ReplyMessageUi({super.key, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    String onlyTime = time.split(' ').length > 1
        ? '${time.split(' ')[1].split(':')[0]}:${time.split(':')[1]}'
        : '${time.split('T')[1].split(':')[0]}:${time.split(':')[1]}';

    return Align(alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(child: Card(
                  elevation: 0,
                  color: lightGrayColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 55),
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(text, style: Theme.of(context).textTheme.bodyMedium)
                      )
                  )
              )),
              Text("$onlyTime ${isRead ? "" : 1/* 단체 채팅이면 방에 있는 사람들-1 만큼 카운트 들어가야 함*/}", style: Theme.of(context).textTheme.labelSmall!.copyWith(color: grayColor)),
              SizedBox(width: 20)
            ],
          ),
        ));
  }
}
