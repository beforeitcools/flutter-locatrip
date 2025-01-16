import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/widget/trip_for_post.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostScreen extends StatefulWidget {
  final int tripId;
  const PostScreen({super.key, required this.tripId});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){Navigator.pop(context);Navigator.pop(context);}, icon: Icon(Icons.arrow_back_outlined)),
          title: Text("글쓰기"),
          actions: [TextButton(onPressed: (){/* 등록하는 로직 넣어주기*/}, child: Text("등록", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: pointBlueColor)))],
        ),
        body: Padding(padding: EdgeInsets.all(16),
            child: Form(child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: grayColor, fontSize: 20),
                          hintText: "제목을 작성해주세요"),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      minLines: 8,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _contentController,
                      decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: grayColor),
                          hintText: "현지인에게 첨삭 받고 싶은 내용을 작성해주세요 \nex) 원하는 여행 스타일, 여행지에 대한 의견"
                      ),
                    ),
                    SizedBox(height: 16),
                    /* 여기에 일정 보여주기 */
                    TripForPost(tripId: widget.tripId)
                  ],
                ),
              )
            )))
    );
  }
}

