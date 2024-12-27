import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OwnMessageUi extends StatelessWidget {
  const OwnMessageUi({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width - 55),
      child: Card(
        color: Colors.white,
        child: Stack(
          children: [
            Text("Hey"),
            Row(
              children: [
                Text("20:58"),
                Text("1")
              ],
            ),
          ],
        ),
      ),);
  }
}
