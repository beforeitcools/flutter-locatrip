import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/mypage/widget/custom_dialog.dart';

class AdviceWriteScreen extends StatefulWidget {
  final int postId;
  final int tripDayLocationId;

  const AdviceWriteScreen(
      {super.key, required this.postId, required this.tripDayLocationId});

  @override
  State<AdviceWriteScreen> createState() => _AdviceWriteScreenState();
}

class _AdviceWriteScreenState extends State<AdviceWriteScreen> {
  late int _postId;
  late int _tripDayLocationId;
  TextEditingController _contentsController = TextEditingController();

  Future<void> _insertAdvice(int postId) async {
    /*if(_contentsController.text.isNotEmpty){
      try{
        Map<String, Object> post = {
          "title" : _titleController.text,
          "contents" : _contentController.text.isNotEmpty ? _contentController.text : "",
          "tripId": widget.tripId,
          "advicedTripData":_tripData,
          "status":1
        };

        int postId = await _postModel.insertNewPost(post, context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PostViewScreen(postId: postId)));
      }catch(e){
        print('포스트를 저장하는 중 에러가 발생했습니다 : $e');
      }
    }else{
      CustomDialog.showOneButtonDialog(context, contentMessage, buttonText, onConfirm)
    }*/
  }

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
    _tripDayLocationId = widget.tripDayLocationId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close_outlined)),
            // tripDayLocationId로 해당 항목의 Location name
            Text(_tripDayLocationId == 0 ? "전체 첨삭" : "강남역"),
          ],
        ),
        actions: [
          TextButton(
              // 등록하는 함수
              onPressed: () {},
              child: Text("등록",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: pointBlueColor)))
        ],
      ),
      body: TextField(
        controller: _contentsController,
        decoration: InputDecoration(
            hintText: "이 장소일정에 대해 첨삭해주세요",
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: grayColor,
                ),
            contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0)),
      ),
    );
  }
}
