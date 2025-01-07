import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChatRoomSetting extends StatefulWidget {
  String chatRoom;
  final int chatroomId;
  ChatRoomSetting({super.key, required this.chatRoom, required this.chatroomId});

  @override
  State<ChatRoomSetting> createState() => _ChatRoomSettingState();
}

class _ChatRoomSettingState extends State<ChatRoomSetting> {

  final ChatModel _chatModel = ChatModel();
  bool _showTextField = false;
  String _buttonText = "";
  TextEditingController _controller = TextEditingController();

  void _toggleTextButton(){
    setState(() {
      _showTextField = !_showTextField; // 토글처럼 쓰기 ^^
      if(!_showTextField)
        {
          _buttonText = _controller.text; // 이러고 데이터베이스에도 저장
        }
    });
  }

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
                                    child: TextButton(onPressed: (){ _toggleTextButton();/*버튼 눌렀을 때 텍스트 편집 할 수 있도록*/},
                                        style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)), //MaterialStateProperty 대신에 WidgetStateProperty 쓰기
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: _showTextField ? 
                                              Row(children: [
                                                Expanded(child:  TextFormField(
                                                  controller: _controller,
                                                  decoration: InputDecoration(
                                                    enabledBorder: InputBorder.none,
                                                      hintText: widget.chatRoom
                                                  ),
                                                )),
                                                TextButton(onPressed: (){
                                                  _chatModel.updateChatroomName(widget.chatroomId, _controller.text);
                                                  _toggleTextButton();}, child: Text("저장", style: Theme.of(context).textTheme.labelMedium!.copyWith(color: pointBlueColor)))
                                                ])
                                              : Text(widget.chatRoom, style: Theme.of(context).textTheme.bodySmall) ,
                                        )) //TODO 20자 넘어가지 못하게 할 것임
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
    );;
  }
}
