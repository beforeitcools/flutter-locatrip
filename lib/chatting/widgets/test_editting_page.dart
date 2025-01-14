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
  late SocketModules _socketModules;
  final _chatModel = ChatModel();
  late int result;

  void _socketInit(){
    _socketModules = SocketModules();
    _socketModules.onMessageReceived = (action, data) {
      switch(action)
      {
        case "startEditing":
          print('이거는 내가 보낸 userId ${data["userId"]}, 이거는 받아온 유저아이디 ${widget.userId}');
          if (data['userId'] != widget.userId) {
            // Notify the user that the page is locked how can Page lock?
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("현재 다른 사용자가 편집 중 입니다")));
            Navigator.pop(context);
            break;
          }
        case "stopEditing":
          print("편집 완료");
          break;
        case "updateSchedule":
          print("내용 갱신");
          break;
      }
    };

    // Connect to the WebSocket server and start editing
    try{
      _socketModules.connect(widget.userId);
      print('소켓 채널과 연결 됐긔욤!!');
      _socketModules.startEditing(widget.userId);
    }catch(e){
      print("연결에 실패했긔욤   $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _socketInit();
  }


  @override
  void dispose() {
    _socketModules.stopEditing(widget.userId);
    _socketModules.disconnect();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("테스트 페이지"),
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: _socketModules.getChannel().stream,
              builder: (context, snapshot){
                if(snapshot.hasData){
                  {print('스냅샷 데이터 : ${snapshot.data}');}
                }
                return Text(snapshot.hasData ? '${snapshot.data}': '스냅샷에 왜 데이터가 없는데 쓰니야 제발 ${snapshot.data}',
                  style: const TextStyle(fontSize: 20),);
              }),
          TextButton(
              onPressed:(){ // 받아올 유저 아이디, 유저 이름, context
              print('결과 제발 미친아');
                },
              child: Text("쓰니야 제발"))
        ],
      )
    );
    // ()async{ await _chatModel.chattingRoomForOTO(1, "user", context); 테스트코드
  }
}
