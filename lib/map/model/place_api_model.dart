import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_key_loader.dart';

class PlaceApiModel {
  Future<Map<String, dynamic>> getNearByPlaces(
      Map<String, dynamic> data) async {
    final dio = Dio();
    String? apiKey = await ApiKeyLoader.getApiKey('PLACES_API_KEY');
    print('apiKey1 : $apiKey');

    try {
      final responses = await dio.post(
        "https://places.googleapis.com/v1/places:searchNearby",
        data: jsonEncode(data),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              "places.id,places.displayName,places.shortFormattedAddress,places.primaryTypeDisplayName,places.location,places.photos",
        }),
      );

      if (responses.statusCode == 200) {
        return responses.data as Map<String, dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<List<Map<String, String>>> getPlacePhotos(List<String> photos) async {
    final dio = Dio();
    String? apiKey = await ApiKeyLoader.getApiKey('PLACES_API_KEY');
    List<Map<String, String>> resultList = [];

    for (String photo in photos) {
      try {
        final responses = await dio.get(
          "https://places.googleapis.com/v1/$photo/media?key=$apiKey&maxWidthPx=800",
        );

        if (responses.statusCode == 200) {
          // 데이터를 Map<String, String>으로 변환
          Map<String, dynamic> responseData =
              responses.data as Map<String, dynamic>;

          // 문자열 변환을 위해 Map<String, String>으로 처리
          Map<String, String> photoData = responseData.map(
            (key, value) => MapEntry(key, value.toString()),
          );

          resultList.add(photoData);

          return resultList;
        } else {
          throw Exception("로드 실패");
        }
      } catch (e) {
        print(e);
        throw Exception("Error : $e");
      }
    }
    return resultList;
  }
}
