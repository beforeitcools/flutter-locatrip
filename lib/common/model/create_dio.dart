import 'dart:async';
import 'dart:io'; // SecurityContext, HttpClient
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // rootBundle
import 'package:dio/dio.dart'; // Dio

class SDio {
  Dio? dio; // Dio 객체를 전역 변수로 선언

  Future<Dio> createDio() async {
    if (dio != null) return dio!; // 이미 Dio 객체가 생성된 경우, 재사용

    dio = Dio();

    // 인증서 파일 로드 (res/raw/ca_bundle.crt)
    final ByteData data = await rootBundle.load('assets/ca_bundle.crt');
    final List<int> bytes = data.buffer.asUint8List();

    // 인증서 파일을 SecurityContext에 추가
    final SecurityContext context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(Uint8List.fromList(bytes));

    // HttpClientAdapter 설정
    dio!.httpClientAdapter = MyHttpClientAdapter(context);

    return dio!;
  }
}

class MyHttpClientAdapter implements HttpClientAdapter {
  final SecurityContext context;

  MyHttpClientAdapter(this.context);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final HttpClient client = HttpClient(context: context);
    final HttpClientRequest request =
        await client.openUrl(options.method, options.uri);

    // 요청 헤더 설정
    options.headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    // 요청 본문 설정
    if (requestStream != null) {
      await request.addStream(requestStream);
    }
    final HttpClientResponse response = await request.close();
    final List<int> responseBytes =
        await consolidateHttpClientResponseBytes(response);

    // HttpHeaders를 Map으로 변환
    final Map<String, List<String>> headers = {};
    response.headers.forEach((name, values) {
      headers[name] = values;
    });

    return ResponseBody.fromBytes(responseBytes, response.statusCode,
        headers: headers);
  }

  @override
  void close({bool force = false}) {
    // 필요한 리소스 해제 코드 작성
  }
}
