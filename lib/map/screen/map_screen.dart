import 'package:flutter/material.dart';
import 'package:flutter_locatrip/map/model/place_api_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/widget/color.dart';
import '../../trip/model/current_position_model.dart';
import '../../trip/widget/denied_permission_dialog.dart';
import '../model/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PlaceApiModel _placeApiModel = PlaceApiModel();
  Set<Marker> _markers = {};

  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final ScrollController _categoryScrollController = ScrollController();

  TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;

  final double maxSize = 0.9;
  final double minSize = 0.47;
  final double tolerance = 0.001;

  bool isExpanded = false;

  List<Place> _nearByPlacesList = [];

  @override
  void initState() {
    super.initState();

    _getGeoData();

    // DraggableScrollableController 의 상태 변화 감지
    sheetController.addListener(() {
      double currentSize = sheetController.size;
      if ((currentSize - maxSize).abs() < tolerance) {
        setState(() {
          isExpanded = true;
        });
      } else if ((currentSize - minSize).abs() < tolerance) {
        setState(() {
          isExpanded = false;
        });
      }
    });
  }

  // 지도에서 현위치 때 사용
  _getGeoData() async {
    try {
      Position? position = await getCurrentPosition();
      print("position $position");
      setState(() {
        latitude = position!.latitude;
        longitude = position!.longitude;
        isLoading = false;
      });
      _moveMapToCurrentLocation();
      _getNearByPlaces(latitude!, longitude!);
    } catch (e) {
      _showPermissionDialog();
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

  void _toggleSheetHeight() {
    if (isExpanded) {
      sheetController.animateTo(
        minSize,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      sheetController.animateTo(
        maxSize,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 근처 장소 검색
  void _getNearByPlaces(double _latitude, double _longitude) async {
    print('_latitude $_latitude _longitude $_longitude');
    Map<String, dynamic> data = {
      "locationRestriction": {
        "circle": {
          "center": {"latitude": _latitude, "longitude": _longitude},
          "radius": 500
        }
      },
      "languageCode": "ko",
      "regionCode": "KR",
      "includedTypes": [
        "convenience_store",
        "grocery_store",
        "cafe",
        "coffee_shop",
        "restaurant",
        "meal_takeaway",
        "meal_delivery",
        "lodging",
        "hotel",
        "motel",
        "guest_house",
        "hostel",
        "tourist_attraction",
        "museum",
        "park",
        "zoo",
        "amusement_park"
      ]
    };

    try {
      Map<String, dynamic> nearByPlaces =
          await _placeApiModel.getNearByPlaces(data);

      print('nearByPlaces : $nearByPlaces');

      List<dynamic> nearByPlacesList = nearByPlaces["places"];
      print('nearByPlacesList $nearByPlacesList');

      // 장소 데이터를 Place 객체로 변환
      List<Place> places = await _processPlacesData(nearByPlacesList);

      // 마커 추가
      _addMarkersToMap(places);

      /*Set<Marker> newMarkers = nearByPlacesList.map((place) {
        final LatLng latLng = LatLng(
          place['location']['latitude'],
          place['location']['longitude'],
        );

        return Marker(
          markerId: MarkerId(place['id']),
          position: latLng,
          */ /*infoWindow: InfoWindow(
            title: place['displayName']['text'],
            // snippet: place['vicinity'],
          ),*/ /*
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
*/
      if (latitude != _latitude || _longitude != longitude) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(_latitude, _longitude)),
        );
      }
    } catch (e) {
      print("에러메시지 : $e");
    }
  }

  // 장소 데이터를 Place 객체 리스트로 변환
  Future<List<Place>> _processPlacesData(List<dynamic> nearByPlacesList) async {
    print('메소드!');
    List<Place> places = [];

    for (var place in nearByPlacesList) {
      final location = LatLng(
        place['location']['latitude'],
        place['location']['longitude'],
      );

      // 사진 가져오기
      List<dynamic>? photoUrl = place['photos'] ?? [];
      print('photoUrl $photoUrl');

      // 아이콘 가져오기 - 한번더 해보고 / 안되면  이미지로 만들어서 가져오기
      /*BitmapDescriptor? icon = await _placeApiModel
              .getMarkerIcon(place['primaryTypeDisplayName']['text']) ??
          null;
      print('icon $icon');*/

      List<String> photoUris = photoUrl!
          .map((photo) => photo["authorAttributions"]?[0]["photoUri"] as String)
          .toList();

      print(place['id'].runtimeType);

      // Place 객체 생성
      places.add(
        Place(
            id: place['id'],
            name: place['displayName']['text'] ?? 'Unknown',
            address: place['shortFormattedAddress'] ?? 'Unknown',
            category: place['primaryTypeDisplayName']['text'] ?? 'Others',
            photoUrl: photoUrl,
            location: location,
            // icon: icon!,
            icon: BitmapDescriptor.defaultMarker),
      );
      setState(() {
        _nearByPlacesList.addAll(places);
      });
    }

    return places;
  }

  // 마커 추가
  void _addMarkersToMap(List<Place> places) {
    Set<Marker> markers = places.map((place) {
      print('marker place ${place.name}');
      return Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        infoWindow: InfoWindow(
          title: place.name.toString(),
          snippet: place.address.toString(),
        ),
        icon: place.icon,
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng _mapCenter = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : LatLng(37.514575, 127.0495556);
    return Scaffold(
        body: Stack(
      children: [
        latitude != null && longitude != null
            ? Container(
                height: 460,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _mapCenter, zoom: 15),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  markers: _markers,
                  onCameraMove: (CameraPosition position) {
                    _mapCenter = position.target;
                    print('onCameraMove _mapCenter $_mapCenter');
                  },
                ),
              )
            : Center(heightFactor: 12, child: CircularProgressIndicator()),
        Padding(
            padding: EdgeInsets.only(top: 370),
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _mapCenter =
                          LatLng(_mapCenter.latitude, _mapCenter.longitude);
                    });
                    print('click _mapCenter $_mapCenter');
                    _getNearByPlaces(_mapCenter.latitude, _mapCenter.longitude);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 40),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        color: blackColor,
                      ),
                      Text(
                        "이 지역에서 검색",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
            )),
        DraggableScrollableSheet(
          initialChildSize: minSize, // 초기 높이 비율
          minChildSize: minSize, // 최소 높이 비율
          maxChildSize: maxSize, // 최대 높이 비율
          controller: sheetController,
          snap: true,
          builder: (BuildContext context, scrollController) {
            return Container(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 드래그 핸들러
                    GestureDetector(
                        onTap: _toggleSheetHeight,
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 4,
                            margin: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: grayColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 35),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: "장소 검색",
                          filled: true,
                          fillColor: lightGrayColor,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24), // 둥근 테두리
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      Icons.cancel,
                                      color: grayColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {});
                                      // if(_searchController.text.isEmpty)
                                    },
                                    icon: Icon(Icons.search))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _categoryScrollController,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                      backgroundColor: lightGrayColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100))),
                                  child: Row(
                                    children: [
                                      Text(
                                        "추천순",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: blackColor,
                                      )
                                    ],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 1,
                                height: 16,
                                color: lightGrayColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                    backgroundColor: lightGrayColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100))),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_convenience_store_outlined,
                                      color: blackColor,
                                      size: 18,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "편의점",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        physics:
                            BouncingScrollPhysics(), // 리스트 수가 적을 때 스크롤 가능 하도록 !
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 16),
                              child: Text("test"));
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        )
      ],
    ));
  }
}
