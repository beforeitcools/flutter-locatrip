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

  bool isSearched = false;
  List<String> orderByList = [];
  String orderBy = "";

  List<String> typeAll = [];
  List<String> typeConvenience = [];
  List<String> typeMart = [];
  List<String> typeCafe = [];
  List<String> typeRestaurant = [];
  List<String> typeLodging = [];
  List<String> typeTourist = [];

  bool isCategorySelected = false;

  @override
  void initState() {
    super.initState();
    orderByList = ["추천순", "거리순"];
    orderBy = orderByList[0];
    typeConvenience = ["convenience_store"];
    typeMart = ["grocery_store"];
    typeCafe = ["cafe", "coffee_shop"];
    typeRestaurant = ["restaurant", "meal_takeaway", "meal_delivery"];
    typeLodging = ["lodging", "hotel", "motel", "guest_house", "hostel"];
    typeTourist = [
      "tourist_attraction",
      "museum",
      "park",
      "zoo",
      "amusement_park"
    ];
    typeAll = [
      ...typeConvenience,
      ...typeMart,
      ...typeCafe,
      ...typeRestaurant,
      ...typeLodging,
      ...typeTourist
    ];
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
      // print("position $position");
      setState(() {
        latitude = position!.latitude;
        longitude = position!.longitude;
        isLoading = false;
      });
      _moveMapToCurrentLocation();
      _getNearByPlaces(latitude!, longitude!, "POPULARITY", typeAll);
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
  void _getNearByPlaces(double _latitude, double _longitude,
      String rankPreference, List typeList) async {
    // print('_latitude $_latitude _longitude $_longitude');

    Map<String, dynamic> data = {
      "locationRestriction": {
        "circle": {
          "center": {"latitude": _latitude, "longitude": _longitude},
          "radius": 500
        }
      },
      "languageCode": "ko",
      "regionCode": "KR",
      "maxResultCount": 10,
      "includedTypes": typeList,
      "rankPreference": rankPreference
    };

    try {
      Map<String, dynamic> nearByPlaces =
          await _placeApiModel.getNearByPlaces(data);

      /*print('nearByPlaces : $nearByPlaces');*/

      List<dynamic> nearByPlacesList = nearByPlaces["places"];
      print('nearByPlacesList $nearByPlacesList');

      // 장소 데이터를 Place 객체로 변환
      List<Place> places = await _processPlacesData(nearByPlacesList);

      // 마커 추가
      _addMarkersToMap(places);

      /*if (latitude != _latitude || _longitude != longitude) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(_latitude, _longitude)),
        );
      }*/
    } catch (e) {
      print("에러메시지 : $e");
    }
  }

  // 장소 데이터를 Place 객체 리스트로 변환
  Future<List<Place>> _processPlacesData(List<dynamic> nearByPlacesList) async {
    List<Place> places = [];

    for (var place in nearByPlacesList) {
      final location = LatLng(
        place['location']['latitude'],
        place['location']['longitude'],
      );

      // 사진 가져오기
      List<dynamic> photos = place['photos'] ?? [];
      List<String> photoUrls = [];
      for (var photo in photos) {
        String? photoUri = photo['name'];
        if (photoUri != null) {
          photoUrls.add(photoUri);
        }
      }

      List<String> photoUris = await _placeApiModel.getPlacePhotos(photoUrls);
      /*  print('photoUris $photoUris');*/

      // 아이콘 가져오기 - 한번더 해보고 / 안되면  이미지로 만들어서 가져오기
      /*BitmapDescriptor? icon = await _placeApiModel
              .getMarkerIcon(place['primaryTypeDisplayName']['text']) ??
          null;
      print('icon $icon');*/

      // print(place['id'].runtimeType);

      // Place 객체 생성
      places.add(
        Place(
            id: place['id'],
            name: place['displayName']['text'] ?? 'Unknown',
            address: place['shortFormattedAddress'] ?? 'Unknown',
            category: place['primaryTypeDisplayName']['text'] ?? 'Others',
            photoUrl: photoUris,
            location: location,
            // icon: icon!,
            icon: BitmapDescriptor.defaultMarker),
      );
      setState(() {
        _nearByPlacesList.clear();
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

  void _getSearchResults() async {
    // 지도에서는 우리나라 제한 검색 / 장소 추가시 해당 지역으로 축소

    print('_searchController ${_searchController.text}');

    Map<String, dynamic> data = {
      "textQuery": _searchController.text.toString(),
      "pageSize": "10",
      "languageCode": "ko",
      "regionCode": "KR"
    };
    try {
      List<dynamic> _resultList = await _placeApiModel.getSearchPlace(data);
      // 장소 데이터를 Place 객체로 변환
      List<Place> places = await _processPlacesData(_resultList);

      // 마커 추가
      _addMarkersToMap(places);
    } catch (e) {
      print("에러메시지 : $e");
    }
  }

  void showAppBarOverlay(BuildContext context) {
    // 1. overlayEntry 선언
    OverlayEntry? overlayEntry;

    // 2. OverlayEntry 설정
    overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          // 3. 화면 전체를 터치하면 overlayEntry를 닫음
          onTap: () {
            overlayEntry?.remove(); // 앱바 닫기
          },
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // GestureDetector로 전체 화면을 감싸서 터치 이벤트 감지
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.white.withOpacity(0.9), // 앱바 배경 색상
                    child: AppBar(
                      title: Text("음식점"),
                      backgroundColor: Colors.white,
                      elevation: 4.0,
                      leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          overlayEntry?.remove(); // x버튼으로 앱바 닫기
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 4. OverlayState 얻기
    OverlayState overlayState = Overlay.of(context)!;

    // 5. Overlay에 앱바 추가
    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    LatLng _mapCenter = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : LatLng(37.514575, 127.0495556);

    List<String> orderByListEn = ["POPULARITY", "DISTANCE"];

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
                  },
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
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
                    // print('click _mapCenter $_mapCenter');
                    _getNearByPlaces(_mapCenter.latitude, _mapCenter.longitude,
                        "POPULARITY", typeAll);
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
                        /*onChanged: (value) {
                          _getSearchResults();
                        },*/
                        decoration: InputDecoration(
                          hintText: "장소 검색",
                          filled: true,
                          fillColor: lightGrayColor,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
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
                                      setState(() {
                                        isSearched = false;
                                      });
                                      _searchController.clear();
                                      _getNearByPlaces(
                                          _mapCenter.latitude,
                                          _mapCenter.longitude,
                                          "POPULARITY",
                                          typeAll);
                                    },
                                  ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isSearched = true;
                                      });
                                      sheetController.animateTo(
                                        maxSize,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                      _getSearchResults();
                                      // if(_searchController.text.isEmpty)
                                    },
                                    icon: Icon(Icons.search))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    isSearched
                        ? SizedBox.shrink()
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _categoryScrollController,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                          ),
                                          builder: (BuildContext context) {
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  16, 0, 16, 16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // 컨텐츠 높이에 맞게 조정
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            orderByList.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color:
                                                                      lightGrayColor,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                            ),
                                                            child: ListTile(
                                                              onTap: () {
                                                                setState(() {
                                                                  print(orderByList[
                                                                      index]);
                                                                  orderBy =
                                                                      orderByList[
                                                                          index];
                                                                });

                                                                _getNearByPlaces(
                                                                    _mapCenter
                                                                        .latitude,
                                                                    _mapCenter
                                                                        .longitude,
                                                                    orderByListEn[
                                                                        index],
                                                                    typeAll);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              title: Text(
                                                                orderByList[
                                                                    index],
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "닫기",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: lightGrayColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100))),
                                      child: Row(
                                        children: [
                                          Text(
                                            orderBy,
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
                                    onPressed: () {
                                      setState(() {
                                        isCategorySelected = true;
                                      });

                                      showAppBarOverlay(context);

                                      _getNearByPlaces(
                                          _mapCenter.latitude,
                                          _mapCenter.longitude,
                                          "POPULARITY",
                                          typeRestaurant);
                                    },
                                    style: TextButton.styleFrom(
                                        backgroundColor: lightGrayColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100))),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.restaurant,
                                          color: blackColor,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "음식점",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ],
                                    ),
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
                                          Icons.local_cafe_outlined,
                                          color: blackColor,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "카페",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ],
                                    ),
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
                                          Icons
                                              .local_convenience_store_outlined,
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
                                          Icons.shopping_cart_outlined,
                                          color: blackColor,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "마트",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ],
                                    ),
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
                                          Icons.bed_outlined,
                                          color: blackColor,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "숙박시설",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ],
                                    ),
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
                                          Icons.attractions_outlined,
                                          color: blackColor,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "관광지",
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
                        child: _nearByPlacesList.isNotEmpty
                            ? ListView.builder(
                                controller: scrollController,
                                physics:
                                    BouncingScrollPhysics(), // 리스트 수가 적을 때 스크롤 가능 하도록 !
                                itemCount: _nearByPlacesList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _nearByPlacesList[index]
                                                        .name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        _nearByPlacesList[index]
                                                            .category,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                                color:
                                                                    grayColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Text(
                                                        " · ${_nearByPlacesList[index].address.split(" ")[0]}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                                color:
                                                                    grayColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                  onPressed: () {},
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(
                                                    Icons
                                                        .favorite_outline_outlined,
                                                  ))
                                            ],
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: _nearByPlacesList[index]
                                                  .photoUrl!
                                                  .map((photo) {
                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      right: 16),
                                                  width: 150,
                                                  height: 90,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:
                                                          NetworkImage(photo),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ))
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
