import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final String address;
  final String category;
  List? photoUrl;
  final LatLng location;
  final BitmapDescriptor icon;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.photoUrl,
    required this.location,
    required this.icon,
  });
}
