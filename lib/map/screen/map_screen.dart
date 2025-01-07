import 'package:flutter/material.dart';
import 'package:flutter_locatrip/map/model/location_model.dart';
import 'package:flutter_locatrip/map/model/place_api_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/model/navigation_observer.dart';
import '../../common/widget/color.dart';
import '../../trip/model/current_position_model.dart';
import '../../trip/widget/denied_permission_dialog.dart';
import '../model/app_overlay_controller.dart';
import '../model/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PlaceApiModel _placeApiModel = PlaceApiModel();
  final LocationModel _locationModel = LocationModel();

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
  double sheetSize = 0.47;
  final double buttonOffset = 16;

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

  bool _isLoadingMarkers = false;

  String _selectedCategory = '';

  Map<String, bool> _favoriteStatus = {};

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
      sheetSize = sheetController.size;
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

    setState(() {
      _isLoadingMarkers = true;
      _nearByPlacesList.clear();
    });

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

      // 마커 추가 전 리스트 클리어
      setState(() {
        _nearByPlacesList.clear();
      });

      // 장소 데이터를 비동기로 처리
      for (var place in nearByPlacesList) {
        _processAndAddPlace(place);
      }

      // 마커 추가
      // _addMarkersToMap(places);

      /*if (latitude != _latitude || _longitude != longitude) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(_latitude, _longitude)),
        );
      }*/
    } catch (e) {
      print("에러메시지 : $e");
    } finally {
      setState(() {
        _isLoadingMarkers = false;
      });
    }
  }

  // 개별 장소 데이터 처리 및 리스트 추가
  void _processAndAddPlace(dynamic place) async {
    final location = LatLng(
      place['location']['latitude'],
      place['location']['longitude'],
    );

    List<dynamic> photos = place['photos'] ?? [];
    List<String> photoUrls = [];
    for (var photo in photos) {
      String? photoUri = photo['name'];
      if (photoUri != null) {
        photoUrls.add(photoUri);
      }
    }

    // 병렬로 사진 가져오기
    List<String> photoUris = await _placeApiModel.getPlacePhotos(photoUrls);

    // 아이콘 가져오기 - 한번더 해보고 / 안되면  이미지로 만들어서 가져오기
    /*BitmapDescriptor? icon = await _placeApiModel
              .getMarkerIcon(place['primaryTypeDisplayName']['text']) ??
          null;
      print('icon $icon');*/

    Place newPlace = Place(
      id: place['id'],
      name: place['displayName']['text'] ?? 'Unknown',
      address: place['shortFormattedAddress'] ?? 'Unknown',
      category: place['primaryTypeDisplayName']['text'] ?? 'Others',
      photoUrl: photoUris,
      location: location,
      icon: BitmapDescriptor.defaultMarker,
    );

    _nearByPlacesList.add(newPlace);

    // 마커 추가 및 장소 리스트 업데이트
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(newPlace.id),
          position: newPlace.location,
          /*infoWindow: InfoWindow(
          title: newPlace.name,
          snippet: newPlace.address,
        ),*/
          icon: newPlace.icon,
          onTap: () {
            // newPlace.id와 일치하는 장소 찾기
            Place? selectedPlace = _nearByPlacesList.firstWhere(
              (place) => place.id == newPlace.id,
              orElse: () => Place(
                id: '',
                name: '정보 없음',
                address: '',
                category: '',
                photoUrl: [],
                location: LatLng(0, 0),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );

            // 장소 정보 하단 시트로 띄우기
            if (selectedPlace.id.isNotEmpty) {
              _showPlaceInfoSheet(selectedPlace);
            }
          }));
    });
  }

  // 장소 정보 하단 시트
  void _showPlaceInfoSheet(Place place) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      elevation: 3.0,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          place.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          softWrap: true,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        place.address,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close))
                ],
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: place.photoUrl!.map((url) {
                    return Container(
                      margin: EdgeInsets.only(right: 8),
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _getSearchResults() async {
    print('_searchController ${_searchController.text}');

    Map<String, dynamic> data = {
      "textQuery": _searchController.text.toString(),
      "pageSize": "10",
      "languageCode": "ko",
      "regionCode": "KR"
    };

    setState(() {
      _isLoadingMarkers = true;
      _nearByPlacesList.clear();
      _markers.clear();
    });

    try {
      List<dynamic> resultList = await _placeApiModel.getSearchPlace(data);
      print('resultList: $resultList');

      // 장소 데이터 비동기 처리 및 마커 추가
      for (var place in resultList) {
        _processAndAddPlace(place);
      }
    } catch (e) {
      print("에러메시지 : $e");
    } finally {
      setState(() {
        _isLoadingMarkers = false;
      });
    }
  }

  // 카테고리 버튼 위젯 빌더
  Widget _buildCategoryButton(
      Map<String, dynamic> category, LatLng _mapCenter) {
    final isSelected = _selectedCategory == category["label"];

    return TextButton(
      onPressed: () {
        setState(() {
          isCategorySelected = true;
          _selectedCategory = category["label"];
        });

        AppOverlayController.showAppBarOverlay(
          context,
          category["label"],
          () {
            setState(() {
              isCategorySelected = false;
              _selectedCategory = '';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _categoryScrollController.animateTo(
                  _categoryScrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
              _getNearByPlaces(
                _mapCenter.latitude,
                _mapCenter.longitude,
                "POPULARITY",
                typeAll,
              );
            });
          },
        );

        _getNearByPlaces(
          _mapCenter.latitude,
          _mapCenter.longitude,
          "POPULARITY",
          category["type"],
        );

        // 카테고리에 따라 스크롤 애니메이션 적용
        if (category["scrollToMin"] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _categoryScrollController.animateTo(
              _categoryScrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }

        if (category["scrollToMax"] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _categoryScrollController.animateTo(
              _categoryScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? pointBlueColor : lightGrayColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Row(
        children: [
          Icon(
            category["icon"],
            color: isSelected ? Colors.white : blackColor,
            size: 18,
          ),
          SizedBox(width: 5),
          Text(
            category["label"],
            style: isSelected
                ? Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.white)
                : Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _showDragableSheet(LatLng _mapCenter,
      List<Map<String, dynamic>> categories, List<String> orderByListEn) {
    return DraggableScrollableSheet(
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
                isCategorySelected
                    ? SizedBox.shrink()
                    : Padding(
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
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              isCategorySelected
                                  ? SizedBox.shrink()
                                  : Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              16)),
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            16, 0, 16, 16),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize
                                                          .min, // 컨텐츠 높이에 맞게 조정
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Flexible(
                                                          child:
                                                              ListView.builder(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      orderByList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          bottom:
                                                                              BorderSide(
                                                                            color:
                                                                                lightGrayColor,
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ListTile(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            // print(orderByList[index]);
                                                                            orderBy =
                                                                                orderByList[index];
                                                                          });

                                                                          _getNearByPlaces(
                                                                              _mapCenter.latitude,
                                                                              _mapCenter.longitude,
                                                                              orderByListEn[index],
                                                                              typeAll);
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        title:
                                                                            Text(
                                                                          orderByList[
                                                                              index],
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                        ),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              "닫기",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
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
                                                        BorderRadius.circular(
                                                            100))),
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
                                      ],
                                    ),
                              Row(
                                children: categories.map((category) {
                                  return Row(
                                    children: [
                                      _buildCategoryButton(
                                          category, _mapCenter),
                                      SizedBox(width: 10),
                                    ],
                                  );
                                }).toList(),
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
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _nearByPlacesList.length,
                            itemBuilder: (context, index) {
                              Place place = _nearByPlacesList[index];
                              bool isFavorite =
                                  _favoriteStatus[place.id] ?? false;
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
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Text(
                                                  _nearByPlacesList[index].name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                  softWrap: true,
                                                ),
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
                                                            color: grayColor,
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
                                                            color: grayColor,
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
                                              onPressed: () {
                                                // 장소 테이블 저장
                                                isFavorite
                                                    ? _removeFavorite(place)
                                                    : _insertLocation(place);

                                                // 클릭된 하트만 색상 채워지기
                                              },
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_outline_outlined,
                                                color: isFavorite
                                                    ? Colors.red
                                                    : null,
                                              )),
                                        ],
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: _nearByPlacesList[index]
                                              .photoUrl!
                                              .map((photo) {
                                            return Container(
                                              margin:
                                                  EdgeInsets.only(right: 16),
                                              width: 150,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(photo),
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
    );
  }

  void _insertLocation(Place place) {
    Map<String, dynamic> placeData = {
      "name": place.name,
      "address": place.address,
      "latitude": place.location.latitude,
      "longitude": place.location.longitude,
      "category": place.category,
      // 유저 아이디 임의로 넣기
      "userId": 1,
    };

    try {
      Map<String, dynamic> result =
          _locationModel.insertLocation(placeData) as Map<String, dynamic>;

      if (result['status'] == 'success') {
        setState(() {
          _favoriteStatus[place.id] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("장소 저장 성공!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("장소 저장에 실패했습니다.")),
        );
      }
    } catch (e) {
      print('에러메세지 : $e');
    }
  }

  // 내 장소 삭제 메서드
  void _removeFavorite(Place place) async {
    Map<String, dynamic> placeData = {
      "name": place.name,
      "address": place.address,
      // 유저 아이디 임의로 넣기
      "userId": 1,
    };

    try {
      // 장소 삭제 API 호출
      Map<String, dynamic> result = await _locationModel
          .deleteFavorite(placeData) as Map<String, dynamic>;

      if (result['status'] == 'success') {
        // 즐겨찾기 상태 업데이트
        setState(() {
          _favoriteStatus[place.id] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("장소 삭제 성공!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("장소 삭제에 실패했습니다.")),
        );
      }
    } catch (e) {
      print('에러메세지 : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    LatLng _mapCenter = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : LatLng(37.514575, 127.0495556);

    List<String> orderByListEn = ["POPULARITY", "DISTANCE"];

    // 카테고리 정보 리스트
    final List<Map<String, dynamic>> categories = [
      {
        "label": "음식점",
        "icon": Icons.restaurant,
        "type": typeRestaurant,
      },
      {
        "label": "카페",
        "icon": Icons.local_cafe_outlined,
        "type": typeCafe,
        "scrollToMin": true,
      },
      {
        "label": "편의점",
        "icon": Icons.local_convenience_store_outlined,
        "type": typeConvenience,
      },
      {
        "label": "마트",
        "icon": Icons.shopping_cart_outlined,
        "type": typeMart,
        "scrollToMax": true,
      },
      {
        "label": "숙박시설",
        "icon": Icons.bed_outlined,
        "type": typeLodging,
        "scrollToMax": true,
      },
      {
        "label": "관광지",
        "icon": Icons.attractions_outlined,
        "type": typeTourist,
      }
    ];

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
        if (_isLoadingMarkers)
          Center(heightFactor: 12, child: CircularProgressIndicator()),
        isCategorySelected
            ? SizedBox.shrink()
            : // 위치 조정된 버튼
            AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                bottom: (screenHeight * sheetSize - 10),
                left: MediaQuery.of(context).size.width * 0.3,
                right: MediaQuery.of(context).size.width * 0.3,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mapCenter =
                            LatLng(_mapCenter.latitude, _mapCenter.longitude);
                        _searchController.clear();
                      });
                      _getNearByPlaces(_mapCenter.latitude,
                          _mapCenter.longitude, "POPULARITY", typeAll);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40), // 버튼 크기 조정
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  ),
                ),
              ),
        _showDragableSheet(_mapCenter, categories, orderByListEn),
        // 드래그 시트 위에 버튼 고정
      ],
    ));
  }
}
