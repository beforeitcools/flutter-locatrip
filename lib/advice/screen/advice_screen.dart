import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/advice_post_screen.dart';
import 'package:flutter_locatrip/advice/screen/advice_view_screen.dart';
import 'package:flutter_locatrip/advice/widget/post_bottom_sheet.dart';
import 'package:flutter_locatrip/advice/widget/post_filter.dart';
import 'package:flutter_locatrip/advice/widget/post_list.dart';
import 'package:flutter_locatrip/advice/widget/recommendations.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreen();
}

class _AdviceScreen extends State<AdviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("지역명", style: Theme.of(context).textTheme.headlineLarge),
          actions: [
            InkWell(
              onTap: (){},
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.notifications_outlined, color: blackColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdviceViewScreen()),
                );
              },
              child: Text(
                '첨삭보기 (임시)',
                style: TextStyle(color: blackColor),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Recommendations(),
            PostFilter(),
            PostList()
          ]),
        floatingActionButton: Container(
          width: 65,
          height: 60,
          child: FloatingActionButton(onPressed: (){
            // showDialog(context: context, builder: (context){return ShortageDialog();});
            showModalBottomSheet(context: context,
              builder: (context){return PostBottomSheet();});
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                Text("글쓰기",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                )]),
          )
        )
    );
  }
}
