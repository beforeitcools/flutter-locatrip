import 'package:flutter_locatrip/map/model/place.dart';

class PlaceDetail {
  final Place place;
  final String phone;
  final double rating;
  final List reviews;
  final String googleMapsUri;

  PlaceDetail(
      {required this.place,
      required this.phone,
      required this.rating,
      required this.reviews,
      required this.googleMapsUri});
}
