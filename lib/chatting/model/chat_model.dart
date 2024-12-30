import 'package:dio/dio.dart';

class ChatModel{
  // String name;
  // bool isGroup;
  // String time;
  // String currentMessage;
  // ChatModel({
  //   required this.name, required this.isGroup, required this.time, required this.currentMessage});

  Future<List<dynamic>> fetchMessageData() async{
    final dio = Dio();
    
    try{
      final response = await dio.get("http://localhost:8082/api/chat/recent");
      if(response.statusCode == 200){
        return response.data as List<dynamic>;
      }else{
        throw Exception("메세지 로드 실패");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> fetchChatRoomData(int chatroomId) async{
    final dio = Dio();

    try{
      final response = await dio.get("http://localhost:8082/api/chat/$chatroomId");
      if(response.statusCode == 200){
        return response.data as List<dynamic>;
      }else{
        throw Exception("메세지 로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }
  
  Future<void> saveMessage(Map<String, dynamic> message) async{
    final dio = Dio();
    
    try{
      final response = await dio.post("http://localhost:8082/sendMessage", data: message);
      if(response.statusCode == 200 || response.statusCode == 201){
        print("메세지를 성공적으로 보내다");
      }else
        {
          throw Exception("메세지 전송에 실패하다. : ${response.statusCode}");
        }
    } catch(e){
      print('오류가 나당~~~~~~');
      throw Exception("Error: $e");
    }
  }

}
