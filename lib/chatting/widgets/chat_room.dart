import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/widgets//chat_room_setting.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, required this.chatroomId, required this.sender});
  final String sender;
  final int chatroomId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatModel _chatModel = ChatModel();
  List<dynamic> _chats = [];
  dynamic _selectedChat;

  void _loadChatsById() async {
    print("${widget.chatroomId} <= 이거는 채팅방 Id");
    List<dynamic> chatData = await _chatModel.fetchChatRoomData(widget.chatroomId);
    _chats = chatData;
    print(_chats);
  }

  @override
  void initState() {
    super.initState();
    _loadChatsById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: (){Navigator.pop(context);},
          child:  Icon(Icons.arrow_back),
        ),
        title: Text(widget.sender),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search), color: grayColor),
          IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomSetting(chatRoom: widget.sender)));}, icon: Icon(Icons.settings_outlined), color: grayColor)
        ],),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              ListView(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 16, bottom: 16),
                      child: IconButton(onPressed: (){}, icon: Icon(Icons.add_circle_outline), color: blackColor, iconSize: 30,),
                    ),
                    Expanded(child: Container(
                      padding: EdgeInsets.only(right: 16, bottom: 16),
                        width: MediaQuery.of(context).size.width - 55,
                        child: Card(
                            elevation: 0,
                            color: Color.fromRGBO(170, 170, 170, 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            child: Row(
                              children: [
                                Expanded(child: TextFormField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 10,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "메세지를 입력하세요",
                                      contentPadding: EdgeInsets.only(left: 20, right: 20, bottom: 15)),
                                )),
                                IconButton(onPressed: (){}, icon: Icon(Icons.send), color: grayColor,)
                              ],
                            )))),
                ]),
              ),
            ],
          ),
        )
    );
  }
}
