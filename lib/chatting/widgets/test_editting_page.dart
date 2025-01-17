import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/model/socket_modules.dart';

class TestEdittingPage extends StatefulWidget {
  TestEdittingPage({super.key, required this.userId});
  final int userId;

  @override
  State<TestEdittingPage> createState() => _TestEdittingPageState();
}

class _TestEdittingPageState extends State<TestEdittingPage> {
  final SocketModules _socketModules = SocketModules();
  final ChatModel _chatModel = ChatModel();
  late bool _editState = false;

  // init 할 때 현재 상태 가져옴
  void _getCurrentEditState() async{
    try{
      bool result = await _socketModules.getEditingState(1, context);
      setState(() {
        _editState = result;
      });
    }catch(e){
      print("edit State 담아오기에 실패 $e");
    }
  }

  void _editMyTrips() async{
    // 1 대신 trip_id 받아오기!!
    try{
      await _socketModules.changeEditingState(1, _editState, context);
      _getCurrentEditState();
    }catch(e){
      print("내 상태 갱신에 실패햇긔");
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentEditState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("테스트 페이지"),
      ),
      body:Column(
        children: [
          ElevatedButton(onPressed: (){_chatModel.chattingRoomForOTO(2, "honeybee", context);}, child: Text("chatroom with 1")),
          TextButton(onPressed: (){_editMyTrips();}, child: Text("상태 변경")),
          TextButton(
              onPressed:(){ // 받아올 유저 아이디, 유저 이름, context
                /*함수로 받아와야 돼*/
              _editState ? Navigator.pop(context)
                  : _editMyTrips();
              },
              child: Text("편집하기")),
          _editState ? Text("편집 불가능")
              : Column(children: [
            Text("편집 가능")
          ],)
        ],
      )    
    );
    // ()async{ await _chatModel.chattingRoomForOTO(1, "user", context); 테스트ㄴ코드
  }
}
