import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/ui/own_message_ui.dart';
import 'package:flutter_locatrip/chatting/ui/reply_message_ui.dart';
import 'package:flutter_locatrip/chatting/widgets//chat_room_setting.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, required this.chatroomId, required this.sender});
  final String sender;
  final int chatroomId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.events')); // 서버 url

  final ChatModel _chatModel = ChatModel();
  final TextEditingController _textController = TextEditingController();
  List<dynamic> _chats = [];
  dynamic _selectedChat;

  int myUserId = 1;

  void _loadChatsById() async {
    List<dynamic> chatData = await _chatModel.fetchChatRoomData(widget.chatroomId);
    setState(() {
      _chats = chatData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChatsById();
  }

  void _sendMessage() async{
    if(_textController.text.isNotEmpty){
      String message = _textController.text;
      _channel.sink.add(message);
      Map<String, dynamic> saveMessage = {
        "chatroomId": widget.chatroomId,
        "userId": myUserId,
        "messageContents": message,
        "sendTime": DateTime.now().toIso8601String()};
      setState(() {
        _chats.add(saveMessage);
        _textController.clear();
      });

      await _chatModel.saveMessage(saveMessage);
    };
  }

  @override
  void dispose() {
    _channel.sink.close();
    _textController.dispose();
    super.dispose();
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
              Container(
                height: MediaQuery.of(context).size.height - 130,
                child: ListView.builder(
                  shrinkWrap: true, // 리스트뷰의 크기를 현재 표시되는 아이템들의 크기에 맞게 자동으로 조절
                  itemCount: _chats.length,
                  itemBuilder: (context, index){
                    final chat = _chats[index];
                    return chat["userId"] == myUserId ? OwnMessageUi(text: chat["messageContents"], time: chat["sendTime"]) : ReplyMessageUi(text: chat["messageContents"], time: chat["sendTime"]); //TODO: userId 확인해서 "나"면 Own, 외에는 Reply
                  },
                ),
              ),
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
                                  controller: _textController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "메세지를 입력하세요",
                                      contentPadding: EdgeInsets.only(left: 20, right: 20, bottom: 15)),
                                )),
                                IconButton(onPressed: (){_sendMessage();}, icon: Icon(Icons.send), color: grayColor,),
                                const SizedBox(height: 24),
                                StreamBuilder(
                                  stream: _channel.stream,
                                  builder: (context, snapshot) {
                                    return Text(snapshot.hasData ? '${snapshot.data}' : '');
                                  },
                                )
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
