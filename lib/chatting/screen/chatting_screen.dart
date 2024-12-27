import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/ui/chat_list_ui.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final ChatModel _chatModel = ChatModel();
  List<dynamic> _chats = [];
  dynamic _selectedChat;

  // List<ChatModel> chats = [
  //   ChatModel(name: "민주", isGroup: false, time: "16:04", currentMessage: "민주주의 만세"),
  //   ChatModel(name: "현지", isGroup: false, time: "11:13", currentMessage: "탄핵하라"),
  //   ChatModel(name: "회먹음이연합", isGroup: true, time: "11:13", currentMessage: "탄핵하라")
  // ];

  void _loadChatData() async
  {
    List<dynamic> chatData = await _chatModel.fetchMessageData();
    setState(() {
      _chats = chatData;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅", style: Theme.of(context).textTheme.headlineLarge),
        actions: [
          InkWell(
            onTap: (){},
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, color: grayColor),
            ),
        )],
      ),
      body: _chats.isEmpty ? Center(child: Text("메세지 불러오는 중"))
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index){
                final chat = _chats[index];
                return ChatListUi(chatroomId: chat["chatroomId"], sender: chat["userId"].toString(), currentMessage: chat["messageContents"],);
              }),
    );
  }
}
