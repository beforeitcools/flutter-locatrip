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
  List<ChatModel> chats = [
    ChatModel(name: "민주", isGroup: false, time: "16:04", currentMessage: "민주주의 만세"),
    ChatModel(name: "현지", isGroup: false, time: "11:13", currentMessage: "탄핵하라"),
    ChatModel(name: "회먹음이연합", isGroup: true, time: "11:13", currentMessage: "탄핵하라")
  ];

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
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) => (ChatListUi(chatModel: chats[index],)),
      ),
    );
  }
}
