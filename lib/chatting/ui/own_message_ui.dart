import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class OwnMessageUi extends StatelessWidget {
  const OwnMessageUi({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Text("Hey 긴 텍스트 테스트 Hey 긴 텍스트 테스트 Hey 긴 텍스트 테스트 Hey 긴 텍스트 테스트", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white))),
              Positioned(
                bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text("20:58"),
                      Text("1")],
              ))
            ],
          ),
        ),));
  }
}
