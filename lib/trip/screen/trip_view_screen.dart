import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/current_position_model.dart';
import '../model/trip_model.dart';

class TripViewScreen extends StatefulWidget {
  final int tripId;

  const TripViewScreen({super.key, required this.tripId});

  @override
  State<TripViewScreen> createState() => _TripViewScreenState();
}

class _TripViewScreenState extends State<TripViewScreen> {
  Map<String, dynamic> tripInfo = {};

  TripModel _tripModel = TripModel();
  bool isLoading = true;

  double? latitude;
  double? longitude;
  late GoogleMapController mapController;

  String address = "";

  @override
  void initState() {
    super.initState();

    _loadInfo();
    // _getGeoData();
  }

  void _loadInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> result = await _tripModel.selectTrip(widget.tripId);
      if (result.isNotEmpty) {
        setState(() {
          tripInfo.addAll(result);
          print(tripInfo);
          address = tripInfo['selectedRegions'][0]['region'];
          isLoading = false;
        });

        if (address.isNotEmpty) {
          _getCoordinatesFromAddress();
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("에러메시지 : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  _getCoordinatesFromAddress() async {
    try {
      List<Location> locations = await locationFromAddress(address);
      setState(() {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
      });

      _moveMapToCurrentLocation();
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

  _getGeoData() async {
    Position? position = await getCurrentPosition();
    if (position == null) {
      _showPermissionDialog();
      return;
    }
    setState(() {
      print('position $position');
      latitude = position.latitude;
      longitude = position.longitude;
      isLoading = false;
    });
    _moveMapToCurrentLocation();
  }

  void _moveMapToCurrentLocation() {
    if (latitude != null && longitude != null && mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(latitude!, longitude!)),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          '위치 권한 필요',
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
        ),
        content: Text(
          '지도를 표시하려면 위치 권한이 필요합니다. 설정에서 권한을 부여해주세요.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '닫기',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: grayColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.pop(context);
            },
            child: Text(
              '설정으로 이동',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: pointBlueColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              // **추가해야함 ! 뒤로 가기 클릭했을 때 마이페이지로 이동 시키기...!!!
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MyPage()),
              //       (Route<dynamic> route) => false,
              // );
            },
            icon: Icon(Icons.arrow_back)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.ios_share)),
          IconButton(
              onPressed: () {}, icon: Icon(Icons.notifications_outlined)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tripInfo.isEmpty
              ? Center(child: Text("여행 정보를 불러올 수 없습니다."))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  tripInfo["title"] ?? "제목 없음",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                                TextButton(onPressed: () {}, child: Text("편집")),
                              ],
                            ),
                            Text(
                              "${tripInfo['startDate'] ?? ''} ~ ${tripInfo['endDate'] ?? ''}",
                            ),
                            TextButton(
                                onPressed: () {}, child: Text("일행과 함께 짜기")),
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () {}, child: Text("체크리스트")),
                                TextButton(
                                    onPressed: () {}, child: Text("가계부")),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (latitude != null && longitude != null)
                        Container(
                          height: 300,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(latitude!, longitude!),
                                zoom: 10),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller; // 지도 컨트롤러 초기화
                            },
                          ),
                        )
                      else
                        Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
    );
  }
}
