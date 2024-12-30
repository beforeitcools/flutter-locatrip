import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<Dio> putTokenHeader(Dio dio) async {
  final storage = new FlutterSecureStorage();

  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  if (accessToken != null) {
    dio.options.headers['Authorization'] = 'BEARER $accessToken';
  }

  return dio;
}
