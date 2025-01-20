import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/widgets/chat_room.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/model/create_dio.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

class ChatModel {
  // 최신 메세지 가져옴
  Future<List<dynamic>> fetchMessageData(BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/api/chat/recent");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("메세지 로드 실패");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // 검색 메세지 가져옴
  Future<List<dynamic>> fetchSearchMessageData(
      String searchKeyword, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/chatroom/search/$searchKeyword");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("메세지 로드 실패");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> fetchChatRoomData(
      int chatroomId, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.get("$backUrl/api/chat/$chatroomId");
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("메세지 로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<void> saveMessage(dynamic message, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.post("$backUrl/sendMessage",
          data: message,
          options: Options(headers: {"Content-Type": "application/json"}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("메세지를 성공적으로 보내다");
      } else {
        throw Exception("메세지 전송에 실패하다. : ${response.statusCode}");
      }
    } catch (e) {
      print('오류가 나당~~~~~~');
      throw Exception("Error: $e");
    }
  }

  Future<void> updateChatroomName(
      int chatroomId, String chatroomName, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    print('$chatroomId 는 나의 채팅방 아이디, $chatroomName 는 내가 바꿀 이름');
    try {
      final response = await dio.post("$backUrl/chatroom/update/$chatroomId",
          data: chatroomName);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("방 이름을 성공적으로 변경하다");
      } else {
        throw Exception("방 이름 변경에 실패하다 : ${response.statusCode}");
      }
    } catch (e) {
      print("room name didn't change");
      throw Exception("Error $e");
    }
  }

  Future<void> chattingRoomForOTO(
      int userId, String chatroomName, BuildContext context) async {
    // 이거는 1:1 one to one 이라서 OTO 했어요 ...
    print("CHATTING ROOM FOR ONE TO ONE");
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    //TODO 새 채팅방 넣는 로직
    // chatroomName 1:1의 경우 상대방의 이름
    // 여행의 경우 trip name 넣기

    try {
      final response = await dio.post("$backUrl/chatroom/onetoone", data: {
        "userId": userId, // 유저 아이디
        "chatroomName": chatroomName // 유저 이름!!
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as int;
        print("채팅방 확인!!!! 넘어가! $result");

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatRoomPage(
                    chatroomId: result, chatroomName: chatroomName)));
      } else {
        throw Exception("FAILED YOUR CHAT ROOM! : ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to make new room");
      throw Exception("Error  $e");
    }
  }

  Future<dynamic> getUnreadMessageCount(
      BuildContext context, int chatroomId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    print("did you come here?");
    try {
      final response = await dio.get("$backUrl/unread/count",
          queryParameters: {"chatroomId": chatroomId});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final unreadCount = response.data as int;
        print("UPDATE GET MY UNREAD COUNT : $unreadCount");
        return unreadCount;
      } else if (response.statusCode == 204) {
        print("No unread messages for chatroom ID: $chatroomId.");
      } else {
        throw Exception(
            "FAILED TO GET MY UNREAD COUNT! : ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print(
          "failed to get your unread message count $e, Stack Trace: $stackTrace");
      throw Exception("Error  $e");
    }
  }

  Future<void> updateLastReadMessage(
      BuildContext context, int chatroomId) async {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    print("updateLastReadMessage --- this is my chatroom Id: $chatroomId");
    try {
      final response = await dio.post("$backUrl/updateLastMessage/$chatroomId");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("UPDATE LAST MESSAGE ID!");
      } else {
        throw Exception(
            "FAILED TO UPDATE LAST MESSAGE ID : ${response.statusCode}");
      }
    } catch (e) {
      print("failed to update your last read message id");
      throw Exception("Error   $e");
    }
  }

  // 기존 채팅방 불러오기(trip)
  Future<int> getExistTripChatroom(BuildContext context, int chatroomId) async{
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try{
      final response = await dio.get("$backUrl/chatroom/createNewChatroom");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Success to get your chatroom!");
        return response.data as int;
      }
      else {
        throw Exception("FAILED TO GET YOUR CHATROOM : ${response.statusCode}");
      }
    }catch(e){
      throw Exception("Error   $e");
    }
  }

  // 채팅방 생성(trip)
  Future<int> createTripChatroom(BuildContext context) async{
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try{
      final response = await dio.post("$backUrl/chatroom/getExistChatroom");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Success to create your chatroom!");
        return response.data as int;
      }
      else {
        throw Exception("FAILED TO CREATE YOUR CHATROOM : ${response.statusCode}");
      }
    }catch(e){
      throw Exception("Error   $e");
    }
  }
}
