import 'package:dio/dio.dart';

class LinkModel{
  final linkRegex = RegExp(r'(https?:\/\/[^\s]+)');

  void detextAndPreviewLink(String message){
    final matches = linkRegex.allMatches(message);
    for(var match in matches){
      final link = match.group(0);
      if(link != null){
        fetchLinkPreview(link); // 서버로 링크 정보 요청
      }
    }
  }

  Future<void> fetchLinkPreview(String link) async{
    final dio = Dio();

    try{
      final response = await dio.get("uri");
      if(response.statusCode == 200){
        return response.data;
      }
    }catch(e){
      print('Error: $e');
    }
  }

}