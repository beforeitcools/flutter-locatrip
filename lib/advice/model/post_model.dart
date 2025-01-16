import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

class PostModel{

  Future<void> insertNewPost(dynamic post, BuildContext context) async{
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try{
      final response = await dio.post(
          "$backUrl/post/new",
          data: post,
          options: Options(
              headers: {"Content-Type": "application/json"}
      ));

      if(response.statusCode == 200){
        print("새 포스트를 썻어염");
      }else{
        throw Exception("메세지 로드 실패");
      }
    } catch (e) {
      print("포스트를 저장하는데 오류가 났어염  $e");
      throw Exception("Error: $e");
    }
  }

}