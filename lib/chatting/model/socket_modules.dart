
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketModules{
  late final WebSocketChannel _channel;
  Function(String action, Map<String, dynamic> data)? onMessageReceived;

  WebSocketChannel getChannel(){
    return _channel;
  }
  void connect(int userId) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://112.221.66.174:8082/chattingServer'));
    // 서버에 연결 알림
    sendMessage({
      "action" : "connect",
      "userId" : userId
    });
  }
  
  void startEditing(int userId){
    sendMessage({
      "action": "startEditing",
      "userId": userId,
    });
  }

  void stopEditing(int userId){
    sendMessage({
      "action": "stopEditing",
      "userId": userId
    });
  }

  void sendMessage(Map<String, dynamic> message){
    final jsonMessage = json.encode(message);
    handleMessage(jsonMessage);
    _channel.sink.add(jsonMessage);
  }

  void handleMessage(String message){
    final data = jsonDecode(message);
    final action = data['action'];

    if (onMessageReceived != null) {
      onMessageReceived!(action, data);
    }
  }

  void showEditTrips(BuildContext context){

    //TODO: 일정 편집 시에 표시 될 모듈
    // 1. Websocket 접속
    // 2. channel에 누가 일정 편집하고 있으면(검사)
    // 3. 편집 중이라고 표시해주고
    // 4. 편집하고 있는 사람이 완료를 누를 때까지 다른 사람이 건드릴 수 없게 함
  }

  void disconnect(){
    print("채널에서 나갔긔윤");
    _channel.sink.close();
  }
}