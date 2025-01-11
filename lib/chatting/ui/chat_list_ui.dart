import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/widgets/chat_room.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ChatListUi extends StatefulWidget {
  ChatListUi({super.key, required this.chatroomId, required this.chatroomName, required this.currentMessage});
  int chatroomId;
  String chatroomName;
  String currentMessage;

  @override
  State<ChatListUi> createState() => _ChatListUiState();
}

class _ChatListUiState extends State<ChatListUi> {
  int _unreadCount = 0;  // 안 읽은 메세지 보여줄 거
  late String token;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final _channel =  WebSocketChannel.connect(Uri.parse("ws://localhost:8082"));
  List<dynamic> _unreadCounts = [];

  Future<void> _getToken() async{
    final dynamic getToken = await _storage.read(key: "ACCESS_TOKEN");
    token = getToken.toString();
  }

  @override
  void initState() {
    super.initState();
    _getToken();
    
    // // 실시간으로 확인하기 위해 websocket 채널 구독
    // _channel.stream.listen((message) {
    //   final data = jsonDecode(message);
    //   setState(() {
    //     _unreadCounts[data['chatroomId']] = data['unreadCount'];
    //   });
    // });
  }

  void _setUnreadCount() {
    // 이녀석은 내가 채팅방에서 나가고 오는 모든 메세지를 unreadCount로 세어야 한다
    // 그럼 계속 백이랑 왓다갓다 해야하는 ....? 100넘어가면 100+로 처리하자

    setState(() {
      _unreadCount = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      hoverColor: Color.fromRGBO(170, 170, 170, 0.1),
      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatRoomPage(token: token,chatroomId: widget.chatroomId, chatroomName: widget.chatroomName)));},
      leading: CircleAvatar(radius: 20),
      title: Text(widget.chatroomName, style: Theme.of(context).textTheme.labelLarge), //TODO: 채팅방이름 sender로 하면 안되고 해당방에 있는 사람 중에 나 제외하고 ... (기본값) 외에 유저가 설정해준 값 할 수 ㅣㅇㅆ음
      subtitle: Text(widget.currentMessage, style: Theme.of(context).textTheme.labelMedium),
      trailing: _unreadCount != 0
          ? CircleAvatar(backgroundColor: pointBlueColor,radius: 9, child: Text(_unreadCount.toString(), style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 10)))
          : null
    );
  }
}
