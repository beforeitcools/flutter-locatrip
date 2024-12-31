import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/page/chat_room_page.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChatListUi extends StatelessWidget {
  final ChatModel chatModel;
  const ChatListUi({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      hoverColor: Color.fromRGBO(170, 170, 170, 0.1),
      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomPage(chatModel: chatModel,)));},
      leading: CircleAvatar(radius: 20),
      title: Text(chatModel.name, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(chatModel.currentMessage, style: Theme.of(context).textTheme.labelMedium),
      trailing: CircleAvatar(backgroundColor: pointBlueColor,radius: 9, child: Text("1", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, fontFamily: 'NotoSansKR', color: Colors.white)),),
    );
  }
}
