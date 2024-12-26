import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChatRoomSetting extends StatelessWidget {
  final String chatRoom;
  const ChatRoomSetting({super.key, required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: (){Navigator.pop(context);},
            child:  Icon(Icons.close),
          ),
        title: Text("채팅방 설정", style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: CircleAvatar(
                    radius: 40,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ))),
              Container(
                padding: EdgeInsets.only(top: 30, bottom: 60),
                child: Row(
                  children: [
                    Text("채팅방 이름", style: Theme.of(context).textTheme.bodyMedium),
                    Expanded(child: Container(
                      child: Text(chatRoom, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right) //TODO 20자 넘어가지 못하게 할 것임
                    ))
                  ])),
              SizedBox(
                width: 300, height: 56,
                child: FilledButton(
                    onPressed: (){Navigator.pop(context); }, //TODO 채팅방 나가는 로직 추가
                    child: Text("채팅방 나가기",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: pointBlueColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                ),
              )
            ]))
      )
    );
  }
}
