import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/map/model/place_api_model.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/custom_dialog.dart';
import 'package:flutter_locatrip/trip/model/current_position_model.dart';
import 'package:flutter_locatrip/trip/widget/denied_permission_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocalAreaAuthScreen extends StatefulWidget {
  /*final String localArea;
  final String localAreaAuthDate;*/

  const LocalAreaAuthScreen({
    super.key,
    /*required this.localArea,
    required this.localAreaAuthDate,*/
  });

  @override
  State<LocalAreaAuthScreen> createState() => _LocalAreaAuthScreenState();
}

class _LocalAreaAuthScreenState extends State<LocalAreaAuthScreen> {
  double? latitude;
  double? longitude;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  Map<String, dynamic> viewPortMap = {};
  String administrativeDistrict = '';
  final PlaceApiModel _placeApiModel = PlaceApiModel();
  final MypageModel _mypageModel = MypageModel();
  String authenticatedLocalArea = '현지인 인증된 지역 없음';
  String authenticatedDate = '현지인 인증된 날짜 없음';
  String daysLeftUntilAuthExpire = '';

  // 지도에서 현위치 때 사용
  _getGeoDataAndAuthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position? position = await getCurrentPosition();
      // print("position $position");
      _moveMapToCurrentLocation();
      setState(() {
        latitude = position!.latitude;
        longitude = position!.longitude;
      });
      await _getAdministrativeDistrict();
      // 현지인 인증 데이터 로드
      Map<String, dynamic> result =
          await _mypageModel.getMyLocalAreaAuthData(context);
      print(result);
      setState(() {
        authenticatedLocalArea = result['localArea'] ?? '현지인 인증된 지역 없음';
        authenticatedDate = result['localAreaAuthDate'] ?? '현지인 인증된 날짜 없음';
      });
    } catch (e) {
      _showPermissionDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateLocalAreaAuthentication(String region) async {
    try {
      LoadingOverlay.show(context);
      Map<String, dynamic> result =
          await _mypageModel.updateLocalAreaAuthentication(context, region);
      print(result);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("인증 완료")));

      setState(() {
        authenticatedLocalArea = result['localArea'];
        authenticatedDate = result['localAreaAuthDate']!;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!현지인 인증중  에러 발생 : $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('트립 삭제 중 오류가 발생했습니다. 다시 시도해주세요.')));
    } finally {
      await _getGeoDataAndAuthData();
      LoadingOverlay.hide();
    }
  }

  // 행정구역명 알아오기
  Future<void> _getAdministrativeDistrict() async {
    try {
      if (latitude == null || longitude == null) return;

      viewPortMap = await _placeApiModel.getViewPortsInKorean(
        LatLng(latitude!, longitude!),
        'ko',
      );
      print('viewport result $viewPortMap');
      print(
          "++++====================================================================");
      if (viewPortMap.containsKey('results') &&
          viewPortMap['results'].isNotEmpty) {
        final addressComponents =
            viewPortMap['results'][0]['address_components'];

        for (var component in addressComponents) {
          print(component);
          if (component['types'].contains('administrative_area_level_1')) {
            setState(() {
              administrativeDistrict = component['long_name'];
            });
            print("Administrative District: $administrativeDistrict");
            break;
          }
        }
      }
    } catch (e) {
      print(
          '------------------------------------------------------------------에러메시지 $e');
    }
  }

  void _moveMapToCurrentLocation() {
    if (latitude != null && longitude != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(latitude!, longitude!)),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => DeniedPermissionDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _getGeoDataAndAuthData();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    LatLng _mapCenter = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : LatLng(37.514575, 127.0495556);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("현지인 인증하기",
                style: Theme.of(context).textTheme.headlineLarge),
          ),
          body: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Center(
                  child: Column(
                    children: [
                      latitude != null && longitude != null
                          ? Container(
                              height: screenHeight / 2.5,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(_mapCenter.latitude,
                                        _mapCenter.longitude),
                                    zoom: 15),
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                },
                                markers: _markers,
                                onCameraMove: (CameraPosition position) {
                                  setState(() {
                                    _mapCenter = position.target;
                                    latitude = _mapCenter.latitude;
                                    longitude = _mapCenter.longitude;
                                    print('_mapCenter $_mapCenter');
                                  });
                                },
                                zoomGesturesEnabled: true,
                                tiltGesturesEnabled: true,
                              ),
                            )
                          : Center(
                              heightFactor: 12,
                              child: CircularProgressIndicator()),
                      SizedBox(
                        height: 16,
                      ),
                      Text(administrativeDistrict.isNotEmpty
                          ? "현재 위치: $administrativeDistrict"
                          : "현재 위치를 가져오는 중..."),
                      SizedBox(
                        height: 16,
                      ),
                      Text("인증된 지역: $authenticatedLocalArea"),
                      SizedBox(
                        height: 16,
                      ),
                      Text("마지막 인증 날짜: $authenticatedDate"),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextButton(
                          onPressed: administrativeDistrict.isEmpty
                              ? null
                              : () {
                                  CustomDialog.show(
                                      context,
                                      "현재 위치 : $administrativeDistrict 로 현지인 인증 하시겠습니까?",
                                      "인증하기",
                                      () => updateLocalAreaAuthentication(
                                          administrativeDistrict));
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "현재 위치로 현지인 인증하기",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                              ),
                            ],
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size(380, 60),
                            backgroundColor: pointBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Image.asset(
                'assets/splash_screen_image.gif',
                width: 100,
                height: 100,
              ),
            ),
          ),
      ],
    );
  }
}
