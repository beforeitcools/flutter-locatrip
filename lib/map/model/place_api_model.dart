import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class PlaceApiModel {
  // place api key가져오기
  Future<String> getApiKey(String keyType) async {
    const platform =
        MethodChannel('com.beforeitcools.flutter_locatrip/secrets');
    try {
      final apiKey = await platform.invokeMethod<String>('getApiKey');
      // print('apikey $apiKey');
      return apiKey ?? '';
    } catch (e) {
      print("Failed to get API key: $e");
      return '';
    }
  }

  Future<List<Map<String, String>>> getNearByPlaces(
      Map<String, dynamic> data) async {
    final dio = Dio();
    String apiKey = await getApiKey("PLACES_API_KEY");
    print('apiKey1 : $apiKey');
    try {
      final responses = await dio.post(
        "https://places.googleapis.com/v1/places:searchNearby",
        data: data,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': '$apiKey', // 여기에 실제 API 키를 넣으세요
          'X-Goog-FieldMask': 'places.displayName',
        }),
      );
      print('responses $responses');
      if (responses.statusCode == 200) {
        return responses.data as List<Map<String, String>>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}
