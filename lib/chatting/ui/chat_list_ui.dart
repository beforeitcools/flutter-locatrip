import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/widgets/chat_room.dart';
import 'package:flutter_locatrip/common/widget/color.dart';


class ChatListUi extends StatefulWidget {
  ChatListUi({super.key, required this.chatroomId, required this.sender, required this.currentMessage});
  int chatroomId;
  String sender;
  String currentMessage;

  @override
  State<ChatListUi> createState() => _ChatListUiState();
}

class _ChatListUiState extends State<ChatListUi> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      hoverColor: Color.fromRGBO(170, 170, 170, 0.1),
      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatRoomPage(chatroomId: widget.chatroomId, sender: widget.sender)));},
      leading: CircleAvatar(radius: 20),
      title: Text(widget.sender, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(widget.currentMessage, style: Theme.of(context).textTheme.labelMedium),
      trailing: CircleAvatar(backgroundColor: pointBlueColor,radius: 9, child: Text("1", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 10)),),
    );
  }
}
