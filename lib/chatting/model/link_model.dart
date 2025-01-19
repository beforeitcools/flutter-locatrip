import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

import '../../common/model/create_dio.dart';

class LinkModel {
  final linkRegex = RegExp(r'(https?:\/\/[^\s]+)');

  void detectAndPreviewLink(String message, BuildContext context) {
    final matches = linkRegex.allMatches(message);
    for (var match in matches) {
      final link = match.group(0);
      if (link != null) {
        fetchLinkPreview(link, context); // 서버로 링크 정보 요청
      }
    }
  }

  Future<void> fetchLinkPreview(String link, BuildContext context) async {
    final SDio sdio = SDio();
    final Dio dio = await sdio.createDio();
    dio.interceptors.add(AuthInterceptor(dio, context));

    try {
      final response = await dio.post('$backUrl/link-preview');
      if (response.statusCode == 200) {
        final previewData = jsonDecode(response.data);
        // 링크 미리보기 데이터 표시 로직 추가
        print(previewData);
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
