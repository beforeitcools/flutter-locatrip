import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'api_key_loader.dart';
import 'custom_icon.dart';

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

  Future<List<dynamic>> getPlacePhotos(List<String> photos) async {
    final dio = Dio();
    String? apiKey = await ApiKeyLoader.getApiKey('PLACES_API_KEY');
    List<dynamic> resultList = [];

    for (String photo in photos) {
      try {
        final responses = await dio.get(
          "https://places.googleapis.com/v1/$photo/media?key=$apiKey&maxWidthPx=800",
        );

        if (responses.statusCode == 200) {
          // 데이터를 Map<String, String>으로 변환
          Map<String, dynamic> responseData =
              responses.data as Map<String, dynamic>;

          resultList.add(responseData["photoUri"]);

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

  // Google Places API에서 마커 아이콘 가져오기
  /* Future<BitmapDescriptor> getMarkerIcon(String category) async {
    final dio = Dio();
    String? apiKey = await ApiKeyLoader.getApiKey('PLACES_API_KEY');

    try {
      final response = await dio.post(
        "https://places.googleapis.com/v1/places:searchText",
        data: jsonEncode({
          "textQuery": category,
          "maxResultCount": 1,
        }),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              "places.iconMaskBaseUri,places.iconBackgroundColor,places.displayName",
        }),
      );

      if (response.statusCode == 200) {
        final placeData = response.data["places"][0];
        final String iconMaskBaseUri = placeData['iconMaskBaseUri'];
        final String iconBackgroundColor = placeData["iconBackgroundColor"];
        print('iconMaskBaseUri : $iconMaskBaseUri');

        final icon = CustomIcon(
          iconMaskBaseUri: "$iconMaskBaseUri.svg",
          iconBackgroundColor: iconBackgroundColor,
        );
        final BitmapDescriptor bitmapDescriptor =
            await icon.getBitmapDescriptor();

        return bitmapDescriptor;
      } else {
        print("아이콘 요청 실패: 응답 코드 ${response.statusCode}");
        return BitmapDescriptor.defaultMarker;
      }
    } catch (e) {
      print("아이콘 요청 실패: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }*/
}
