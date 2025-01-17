import 'package:flutter/material.dart';
import '../model/location_model.dart';
import '../model/place.dart';

class ToggleFavorite {
  final LocationModel _locationModel = LocationModel();

  Future<void> insertLocation(
      Place place, BuildContext context, VoidCallback onUpdate) async {
    Map<String, dynamic> placeData = {
      "googleId": place.id,
      "name": place.name,
      "address": place.address,
      "latitude": place.location.latitude,
      "longitude": place.location.longitude,
      "category": place.category
    };

    try {
      Map<String, dynamic> result =
          await _locationModel.insertFavorite(placeData, context);
      print('result $result');

      if ((result != null && result is Map<String, dynamic>)) {
        onUpdate();
      }
    } catch (e) {
      print('에러메세지 : $e');
    }
  }

  Future<void> removeFavorite(
      Place place, BuildContext context, VoidCallback onUpdate) async {
    String googleId = place.id;

    try {
      String result = await _locationModel.deleteFavorite(googleId, context);

      if (result != null) {
        onUpdate();
      }
    } catch (e) {
      print('에러메세지 : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류가 발생했습니다: $e")),
      );
    }
  }

  void toggleFavoriteStatus(Place place, bool isFavorite, BuildContext context,
      VoidCallback onUpdate) {
    bool _isFavorite = isFavorite ?? false;
    print('현재 상태: $_isFavorite');

    if (_isFavorite) {
      removeFavorite(place, context, onUpdate);
    } else {
      insertLocation(place, context, onUpdate);
    }
  }
}
