import 'package:flutter/material.dart';
import 'package:flutter_locatrip/map/model/location_model.dart';
import 'package:flutter_locatrip/map/model/place_api_model.dart';
import 'package:flutter_locatrip/map/screen/location_detail_screen.dart';
import 'package:flutter_locatrip/map/widget/map_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/model/navigation_observer.dart';
import '../../common/widget/color.dart';
import '../../trip/model/current_position_model.dart';
import '../../trip/widget/denied_permission_dialog.dart';
import '../model/app_overlay_controller.dart';
import '../model/distance_method.dart';
import '../model/place.dart';
import '../model/toggle_favorite.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PlaceApiModel _placeApiModel = PlaceApiModel();
  final LocationModel _locationModel = LocationModel();
  final ToggleFavorite _toggleFavorite = ToggleFavorite();

  final FocusNode _focusNode = FocusNode();

  Set<Marker> _markers = {};

  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final ScrollController _categoryScrollController = ScrollController();

  TextEditingController _searchController = TextEditingController();

  bool isLoading = true; // 지도

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;

  final double maxSize = 0.9;
  final double minSize = 0.34;
  final double tolerance = 0.001;
  double sheetSize = 0.47;

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
  bool isSearchLoading = false;
  bool isSearchLoaded = false;
  // List<Map<String, bool>> _favoriteStatusList = [];

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

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // TextField에 커서가 놓일 때 실행할 동작
        print("TextField is focused");
        sheetController.animateTo(
          maxSize,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // TextField에서 포커스가 벗어날 때 실행할 동작
        print("TextField lost focus");
        sheetController.animateTo(
          minSize,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
      _markers.clear();
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

      if (nearByPlaces.isNotEmpty) {
        List<dynamic> nearByPlacesList = nearByPlaces["places"];
        print('nearByPlacesList $nearByPlacesList');
        // 마커 추가 전 리스트 클리어
        setState(() {
          _nearByPlacesList.clear();
        });

        if (nearByPlacesList.isNotEmpty) {
          // 장소 데이터를 비동기로 처리
          for (var place in nearByPlacesList) {
            _processAndAddPlace(place);
          }
        }
      } else {
        isSearchLoaded = true;
      }
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
      name: place['displayName']['text'] ?? '',
      address: place['shortFormattedAddress'] ?? '',
      category: place['primaryTypeDisplayName']?['text'] ?? '',
      photoUrl: photoUris,
      location: location,
      icon: BitmapDescriptor.defaultMarker,
    );

    _nearByPlacesList.add(newPlace);
    _syncFavoriteStatus();

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
            if (selectedPlace != null && selectedPlace.id.isNotEmpty) {
              selectedPlace = Place(
                id: selectedPlace.id,
                name: selectedPlace.name,
                address: selectedPlace.address,
                category: selectedPlace.category,
                photoUrl: selectedPlace.photoUrl,
                location: LatLng(
                  selectedPlace.location.latitude - 0.002, // latitude 값 수정
                  selectedPlace.location.longitude,
                ),
                icon: selectedPlace.icon,
              );

              mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                    LatLng(selectedPlace.location.latitude,
                        selectedPlace.location.longitude),
                    16.0),
              );

              _showPlaceInfoSheet(selectedPlace);
            }
          }));
      isSearchLoading = false;
      isSearchLoaded = false;
    });
  }

  Future<void> _navigateAndDisplaySelection(
      BuildContext context, Place place) async {
    final isFavorite = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LocationDetailScreen(place: place)),
    );
    setState(() {
      print('isFavorite $isFavorite');
      _favoriteStatus[place.name] = isFavorite;
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
                GestureDetector(
                    onTap: () {
                      _navigateAndDisplaySelection(context, place);
                    },
                    child: Row(
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
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                place.address,
                                style: Theme.of(context).textTheme.bodySmall,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close))
                      ],
                    )),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: place.photoUrl!.map((url) {
                      return GestureDetector(
                          onTap: () {
                            _navigateAndDisplaySelection(context, place);
                          },
                          child: Container(
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
                          ));
                    }).toList(),
                  ),
                ),
              ]),
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
      "regionCode": "KR",
      "locationRestriction": {
        "rectangle": {
          "low": {"latitude": 33.0, "longitude": 124.0},
          "high": {"latitude": 38.5, "longitude": 132.0}
        }
      }
    };

    setState(() {
      _isLoadingMarkers = true;
      _nearByPlacesList.clear();
      _markers.clear();
      isSearchLoading = true;
    });

    try {
      /*// 지도 중심 위치 얻기
      LatLng mapCenter = await mapController!.getLatLng(
        ScreenCoordinate(
          x: MediaQuery.of(context).size.width ~/ 2, // 화면 너비의 절반
          y: MediaQuery.of(context).size.height ~/ 2, // 화면 높이의 절반
        ),
      );
      double mapCenterLat = mapCenter.latitude;
      double mapCenterLng = mapCenter.latitude;
      print('지도중심 $mapCenter');*/

      List<dynamic> resultList = await _placeApiModel.getSearchPlace(data);
      List<dynamic> filteredResultList = resultList.where((place) {
        double latitude = place['location']['latitude'];
        double longitude = place['location']['longitude'];
        double minLatitude = 33.0; // 남쪽
        double maxLatitude = 38.5; // 북쪽
        double minLongitude = 124.0; // 서쪽
        double maxLongitude = 132.0; // 동쪽

        // 대한민국 범위 내에 있는지 확인
        return latitude >= minLatitude &&
            latitude <= maxLatitude &&
            longitude >= minLongitude &&
            longitude <= maxLongitude;
      }).toList();
      print('filteredResultList: $filteredResultList');

      /*// 거리 계산하여 정렬
      filteredResultList.sort((a, b) {
        double aLat = a['location']['latitude'];
        double aLng = a['location']['longitude'];
        double bLat = b['location']['latitude'];
        double bLng = b['location']['longitude'];

        double distanceA =
            calculateDistance(mapCenterLat, mapCenterLng, aLat, aLng);
        double distanceB =
            calculateDistance(mapCenterLat, mapCenterLng, bLat, bLng);

        return distanceA.compareTo(distanceB); // 가까운 순으로 정렬
      });*/

      if (filteredResultList.isNotEmpty) {
        setState(() {
          isSearchLoading = true;
          isSearchLoaded = false;
        });

        mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(
              filteredResultList[0]['location']['latitude'] - 0.005,
              filteredResultList[0]['location']['longitude'])),
        );
        // 장소 데이터 비동기 처리 및 마커 추가
        for (var place in filteredResultList) {
          _processAndAddPlace(place);
        }
      } else {
        setState(() {
          isSearchLoaded = true;
          isSearchLoading = false;
        });
      }
    } catch (e) {
      print("에러메시지 : $e");
    } finally {
      setState(() {
        _isLoadingMarkers = false;
      });
    }
  }

  void _toggleCategoryClick(Map<String, dynamic> category, LatLng _mapCenter) {
    if (isCategorySelected) {
      setState(() {
        AppOverlayController.removeOverlay();
        isCategorySelected = false;
        _selectedCategory = '';

        _getNearByPlaces(
          _mapCenter.latitude,
          _mapCenter.longitude,
          "POPULARITY",
          typeAll,
        );
      });
    } else {
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
    }
  }
/*
  void _onSearchResultClick(Place place) {
    // 카메라를 마커 위치로 이동
    mapController?.animateCamera(
      CameraUpdate.newLatLng(
          LatLng(place.location.latitude - 0.005, place.location.longitude)),
    );
  }*/

  // 카테고리 버튼 위젯 빌더
  Widget _buildCategoryButton(
      Map<String, dynamic> category, LatLng _mapCenter) {
    final isSelected = _selectedCategory == category["label"];

    return TextButton(
      onPressed: () {
        _toggleCategoryClick(category, _mapCenter);
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
      initialChildSize: 0.47, // 초기 높이 비율
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
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: (value) {
                            setState(() {
                              sheetController.animateTo(
                                maxSize,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "장소 검색",
                            filled: true,
                            fillColor: lightGrayColor,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(99),
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
                                          isSearchLoaded = false;
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
                    child: isSearchLoading
                        ? Center(
                            child: CircularProgressIndicator(), // 로딩 스피너
                          )
                        : _nearByPlacesList.isNotEmpty
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
                                      _favoriteStatus[place.name] ?? false;
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        _navigateAndDisplaySelection(
                                            context, place);
                                      },
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    child: Text(
                                                      _nearByPlacesList[index]
                                                          .name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
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
                                                                color:
                                                                    grayColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      if (_nearByPlacesList[
                                                                      index]
                                                                  .category !=
                                                              "" &&
                                                          _nearByPlacesList[
                                                                      index]
                                                                  .address !=
                                                              '')
                                                        Text(" · "),
                                                      Text(
                                                        _nearByPlacesList[index]
                                                            .address
                                                            .split(" ")[0],
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
                                                  onPressed: () {
                                                    _toggleFavorite
                                                        .toggleFavoriteStatus(
                                                            place,
                                                            isFavorite,
                                                            // _favoriteStatus,
                                                            // _favoriteStatusList,
                                                            context,
                                                            () => _updateFavoriteStatus(
                                                                !(_favoriteStatus[
                                                                        _nearByPlacesList[index]
                                                                            .name] ??
                                                                    false),
                                                                _nearByPlacesList[
                                                                    index]));
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
                            : isSearchLoaded
                                ? Center(child: Text("검색 결과가 없습니다."))
                                : SizedBox.shrink())
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncFavoriteStatus() async {
    print('실행돼?');
    List<String> locationNameList =
        _nearByPlacesList.map((place) => place.name).toList();

    // 서버에서 즐겨찾기 상태 동기화
    List<Map<String, bool>>? fetchedStatusList = await _locationModel
        .fetchFavoriteStatusFromServer(locationNameList, context);

    print('fetchedStatusList $fetchedStatusList');

    if (fetchedStatusList != null) {
      setState(() {
        for (Map<String, bool> fetchedStatus in fetchedStatusList) {
          fetchedStatus.forEach((id, isFavorite) {
            _favoriteStatus[id] = isFavorite;
          });
        }
      });
    }
  }

  void _updateFavoriteStatus(bool isFavorite, Place place) {
    setState(() {
      _favoriteStatus[place.name] = isFavorite;
      /*if (isFavorite) {
        _favoriteStatusList.add(_favoriteStatus);
      } else {
        _favoriteStatusList.remove(_favoriteStatus);
      }

      print('_favoriteStatusList $_favoriteStatusList');*/
    });
  }

  @override
  void dispose() {
    // FocusNode 정리
    _focusNode.dispose();

    // ScrollController 정리
    _categoryScrollController.dispose();

    // TextEditingController 정리
    _searchController.dispose();

    super.dispose();
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
                // height: 460,
                height: MediaQuery.of(context).size.height - 80,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                          _mapCenter.latitude - 0.004, _mapCenter.longitude),
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
            : Center(heightFactor: 12, child: CircularProgressIndicator()),
        if (_isLoadingMarkers)
          Center(heightFactor: 12, child: CircularProgressIndicator()),
        isCategorySelected
            ? SizedBox.shrink()
            : // 위치 조정된 버튼
            AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                bottom: screenHeight * sheetSize - 16,
                left: MediaQuery.of(context).size.width * 0.5 - 75,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _nearByPlacesList.clear();
                      });
                      print('_mapCenter $_mapCenter');
                      _getNearByPlaces(_mapCenter.latitude,
                          _mapCenter.longitude, "POPULARITY", typeAll);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                      backgroundColor: Colors.white,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
