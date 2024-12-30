import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/ui/chat_list_ui.dart';
import 'package:flutter_locatrip/chatting/widgets/websocket_page.dart';
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
      body: _chats.isEmpty ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("대화 목록이 아직 없어요", style: Theme.of(context).textTheme.titleMedium),
              Text("여행을 위한 소통을 시작해 보세요!", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: pointBlueColor)),
        ],
      ))
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index){
                final chat = _chats[index];
                return ChatListUi(chatroomId: chat["chatroomId"], sender: chat["userId"].toString(), currentMessage: chat["messageContents"]);
              }),
      floatingActionButton: FloatingActionButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>WebsocketPage()));}, child: Text("눌러"),)
    );
  }
}
