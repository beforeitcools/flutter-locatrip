import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/place.dart';

class MapWidget extends StatefulWidget {
  final LatLng mapCenter;
  final GoogleMapController? mapController;
  final Set<Marker> markers;
  const MapWidget(
      {super.key,
      required this.mapCenter,
      required this.mapController,
      required this.markers});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late LatLng _mapCenter;
  late GoogleMapController? mapController;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();

    _mapCenter = widget.mapCenter;
    mapController = widget.mapController;
    _markers = widget.markers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 460,
      height: MediaQuery.of(context).size.height - 80,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(_mapCenter.latitude - 0.005, _mapCenter.longitude),
            zoom: 15),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: _markers,
        onCameraMove: (CameraPosition position) {
          _mapCenter = position.target;
        },
        zoomGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }
}
