import 'dart:convert';

import 'package:dio/dio.dart';

class LinkModel{
  final linkRegex = RegExp(r'(https?:\/\/[^\s]+)');

  void detectAndPreviewLink(String message){
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
      final response = await dio.post('http://localhost:8082/link-preview');
      if(response.statusCode == 200){
        final previewData = jsonDecode(response.data);
        // 링크 미리보기 데이터 표시 로직 추가
        print(previewData);
      }
    }catch(e){
      print('Error: $e');
    }
  }

}