import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../map/model/app_overlay_controller.dart';
import '../../map/model/distance_method.dart';
import '../../map/model/location_model.dart';
import '../../map/model/place.dart';
import '../../map/model/place_api_model.dart';
import '../../map/screen/location_detail_screen.dart';
import '../widget/denied_permission_dialog.dart';

class SearchPlaceScreen extends StatefulWidget {
  final Map<String, dynamic> tripInfo;

  const SearchPlaceScreen({
    super.key,
    required this.tripInfo,
  });

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  List<GlobalKey> _keys = [];
  late Map<String, dynamic> _tripInfo;

  final PlaceApiModel _placeApiModel = PlaceApiModel();
  final LocationModel _locationModel = LocationModel();
  final FocusNode _focusNode = FocusNode();

  Set<Marker> _markers = {};

  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  final ScrollController _categoryScrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true; // 지도 로딩

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
  bool isSearchLoading = false;
  bool isSearchLoaded = false;

  Map<String, dynamic> viewPortMap = {};
  List<Map<String, dynamic>> viewPortMapList = [];

  @override
  void initState() {
    super.initState();

    _tripInfo = widget.tripInfo;
    print('_tripInfo $_tripInfo');
    latitude = _tripInfo["latitude"];
    longitude = _tripInfo["longitude"];

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
          FocusScope.of(context).unfocus();
          isExpanded = false;
        });
      }
    });

    _focusNode.addListener(() {
      if (sheetController.isAttached) {
        if (_focusNode.hasFocus) {
          if (isExpanded) {
            setState(() {
              isExpanded = false;
            });
          }
          sheetController.animateTo(
            maxSize,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        } else {
          if (!isExpanded) {
            setState(() {
              isExpanded = true;
            });
          }
          sheetController.animateTo(
            minSize,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    _getNearByPlaces(latitude!, longitude!, "POPULARITY", typeAll);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSheetHeight() {
    if (isExpanded) {
      FocusScope.of(context).unfocus();
      sheetController.animateTo(
        minSize,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    } else {
      sheetController.animateTo(
        maxSize,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "날짜 없음";
    DateTime date = DateTime.parse(dateString);
    return DateFormat('y년 M월 d일').format(date);
  }

  // 지역명 리스트로 뷰포트 찾기
  Future<void> getViewportsForRegions(List<dynamic> selectedRegions) async {
    viewPortMapList.clear();

    for (var regionData in selectedRegions) {
      try {
        String region = regionData['region'];
        print('region$region');
        Map<String, dynamic> result = await _placeApiModel.getViewPorts(region);

        if (result != null &&
            result["results"] != null &&
            result["results"].isNotEmpty) {
          print('뷰포트result $result');

          var geometry = result["results"][0]["geometry"];
          var bounds = geometry["bounds"];
          var viewport = geometry["viewport"];

          // `bounds`가 null인 경우 `viewport` 사용
          var southwest = bounds?["southwest"] ?? viewport["southwest"];
          var northeast = bounds?["northeast"] ?? viewport["northeast"];

          viewPortMap = {
            "locationBias": {
              "rectangle": {
                "low": {
                  "latitude": southwest["lat"] ?? 0.0,
                  "longitude": southwest["lng"] ?? 0.0
                },
                "high": {
                  "latitude": northeast["lat"] ?? 0.0,
                  "longitude": northeast["lng"] ?? 0.0
                }
              }
            }
          };

          viewPortMapList.add(viewPortMap);
          print('viewPortMap: $viewPortMap');
        } else {
          print('Invalid result received for region: $region');
        }
      } catch (e) {
        print('Error while processing region: $e');
      }
    }

    print('Final : $viewPortMapList');
    await _getSearchResults(viewPortMapList);
  }

  // 근처 장소 검색
  void _getNearByPlaces(double _latitude, double _longitude,
      String rankPreference, List typeList) async {
    setState(() {
      _isLoadingMarkers = true;
      _nearByPlacesList.clear();
      _markers.clear();
    });

    Map<String, dynamic> data = {
      "locationRestriction": {
        "circle": {
          "center": {"latitude": _latitude, "longitude": _longitude},
          "radius": 10000
        }
      },
      "languageCode": "ko",
      "regionCode": "KR",
      "maxResultCount": 10,
      "includedTypes": typeList,
      "rankPreference": rankPreference,
    };

    try {
      Map<String, dynamic> nearByPlaces =
          await _placeApiModel.getNearByPlaces(data);

      print('nearByPlaces : $nearByPlaces');
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
      print("에러메시지2 : $e");
    } finally {
      setState(() {
        _isLoadingMarkers = false;
      });
    }
  }

  /* void _onMarkerTapped(int index) {
    print('index$index');
    // GlobalKey를 사용하여 해당 항목의 위치를 찾음
    print('_keys$_keys');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final context = _keys[index].currentContext;
        print('context$context');

        if (context != null) {
          final renderBox = context.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero); // 화면에서의 위치를 추출
          print('position$position');

          // DraggableScrollableController로 스크롤 이동
          sheetController.animateTo(
            position.dy, // 항목의 위치
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }*/

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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LocationDetailScreen(place: place)));
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LocationDetailScreen(place: place)));
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
    _keys = List.generate(_nearByPlacesList.length, (index) => GlobalKey());

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
                    15.0),
              );
              /*int tappedIndex = _nearByPlacesList.indexOf(newPlace);
              print('tapped$tappedIndex');*/
              // _onMarkerTapped(tappedIndex);
              _showPlaceInfoSheet(selectedPlace);
              // 새로운 장소 등록 시키는 팝업 추가
            }
          }));
      isSearchLoading = false;
      isSearchLoaded = false;
    });
  }

  // 검색결과 찾기
  Future<void> _getSearchResults(
      List<Map<String, dynamic>> viewPortMapList) async {
    setState(() {
      _isLoadingMarkers = true;
      _nearByPlacesList.clear();
      _markers.clear();
      isSearchLoading = true;
    });

    List<dynamic> aggregatedResults = [];

    try {
      // 지도 중심 위치 얻기
      LatLng mapCenter = await mapController!
          .getLatLng(ScreenCoordinate(x: 0, y: 0)); // (중앙 좌표 추출)
      double mapCenterLat = mapCenter.latitude;
      double mapCenterLng = mapCenter.longitude;
      print('mapCenter $mapCenter');

      for (var viewPortMap in viewPortMapList) {
        print('Searching with viewPortMap: $viewPortMap');

        Map<String, dynamic> data = {
          "textQuery": _searchController.text.toString(),
          "pageSize": "10",
          "languageCode": "ko",
          "regionCode": "KR",
          ...viewPortMap,
        };

        List<dynamic> resultList = await _placeApiModel.getSearchPlace(data);
        print(
            'ResultList for current viewport:${resultList.length} $resultList');

        if (resultList.isNotEmpty) {
          // 결과를 aggregatedResults에 추가
          aggregatedResults.addAll(resultList);
        }
      }

      // 모든 viewPortMap 결과 합친 후 처리
      print('Aggregated Results before filtering: $aggregatedResults');

      // 최종 필터링 (중복 제거 및 거리 기반 필터링)
      List<dynamic> filteredResults = aggregatedResults.where((place) {
        final double placeLat = place['location']['latitude'];
        final double placeLng = place['location']['longitude'];

        // 지도중심에서 50km 이내
        double distanceFromCenter =
            calculateDistance(mapCenterLat, mapCenterLng, placeLat, placeLng);

        return distanceFromCenter <= 50;
      }).toList();

      // 거리 계산하여 정렬
      filteredResults.sort((a, b) {
        double aLat = a['location']['latitude'];
        double aLng = a['location']['longitude'];
        double bLat = b['location']['latitude'];
        double bLng = b['location']['longitude'];

        double distanceA =
            calculateDistance(mapCenterLat, mapCenterLng, aLat, aLng);
        double distanceB =
            calculateDistance(mapCenterLat, mapCenterLng, bLat, bLng);

        return distanceA.compareTo(distanceB); // 가까운 순으로 정렬
      });

      print('Filtered and Sorted Results: $filteredResults');

      if (filteredResults.isNotEmpty) {
        // 정렬된 결과에서 마커 추가
        for (var place in filteredResults) {
          _processAndAddPlace(place); // 비동기적으로 마커 추가 처리
        }

        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
              LatLng(filteredResults[0]["location"]["latitude"],
                  filteredResults[0]["location"]["longitude"]),
              15.0),
        );
      } else {
        setState(() {
          isSearchLoading = false;
          isSearchLoaded = true;
        });
      }
    } catch (e) {
      print("Error while processing viewports: $e");
    } finally {
      setState(() {
        _isLoadingMarkers = false;
      });
    }

    if (aggregatedResults.isEmpty) {
      setState(() {
        isSearchLoaded = true;
      });
    }
  }

  // 카테고리 토글클릭
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
                duration: Duration(milliseconds: 100),
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
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        });
      }

      if (category["scrollToMax"] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _categoryScrollController.animateTo(
            _categoryScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    String dateRange = _tripInfo['startDate'] == _tripInfo['endDate']
        ? "${formatDate(_tripInfo['startDate'])}"
        : "${formatDate(_tripInfo['startDate'])} ~ ${formatDate(_tripInfo['endDate'])}";

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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tripInfo["title"],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              dateRange,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: grayColor),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          latitude != null && longitude != null
              ? Container(
                  // height: 460,
                  height: MediaQuery.of(context).size.height - 80,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            _mapCenter.latitude - 0.05, _mapCenter.longitude),
                        zoom: 11),
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
                  bottom: screenHeight * sheetSize - 16,
                  left: MediaQuery.of(context).size.width * 0.5 - 75,
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
          DraggableScrollableSheet(
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
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
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                },
                                onSubmitted: (value) {
                                  setState(() {
                                    isSearched = true;
                                  });
                                  sheetController.animateTo(
                                    maxSize,
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                  );

                                  getViewportsForRegions(
                                      _tripInfo["selectedRegions"]);
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
                                                duration:
                                                    Duration(milliseconds: 100),
                                                curve: Curves.easeInOut,
                                              );

                                              getViewportsForRegions(
                                                  _tripInfo["selectedRegions"]);
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
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        16)),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        return Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(16, 0,
                                                                  16, 16),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min, // 컨텐츠 높이에 맞게 조정
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Flexible(
                                                                child: ListView
                                                                    .builder(
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
                                                                              border: Border(
                                                                                bottom: BorderSide(
                                                                                  color: lightGrayColor,
                                                                                  width: 1,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                ListTile(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  // print(orderByList[index]);
                                                                                  orderBy = orderByList[index];
                                                                                });

                                                                                _getNearByPlaces(_mapCenter.latitude, _mapCenter.longitude, orderByListEn[index], typeAll);
                                                                                Navigator.pop(context);
                                                                              },
                                                                              title: Text(
                                                                                orderByList[index],
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                              ),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    "닫기",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ))
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          lightGrayColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
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
                                                        Icons
                                                            .keyboard_arrow_down,
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
                                        _keys[index] = GlobalKey();
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final context =
                                              _keys[index].currentContext;
                                          if (context != null) {
                                            final renderBox =
                                                context.findRenderObject()
                                                    as RenderBox;
                                            final position = renderBox
                                                .localToGlobal(Offset.zero);
                                            print(
                                                "Position of item $index: $position");
                                          }
                                        });

                                        return Container(
                                          key: _keys[index],
                                          padding: EdgeInsets.fromLTRB(
                                              16, 0, 16, 16),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LocationDetailScreen(
                                                            place: place,
                                                          )));
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                          child: Text(
                                                            _nearByPlacesList[
                                                                    index]
                                                                .name,
                                                            style: Theme.of(
                                                                    context)
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
                                                              _nearByPlacesList[
                                                                      index]
                                                                  .category,
                                                              style: Theme.of(
                                                                      context)
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
                                                              Text(" · ",
                                                                  style: TextStyle(
                                                                      color:
                                                                          grayColor)),
                                                            Text(
                                                              _nearByPlacesList[
                                                                      index]
                                                                  .address
                                                                  .split(
                                                                      " ")[0],
                                                              style: Theme.of(
                                                                      context)
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
                                                    TextButton(
                                                        onPressed: () {
                                                          Map<String, dynamic>
                                                              selected = {
                                                            "place":
                                                                _nearByPlacesList[
                                                                    index],
                                                            "day": _tripInfo[
                                                                "day"],
                                                            "dateIndex": index
                                                          };
                                                          AppOverlayController
                                                              .removeOverlay();
                                                          Navigator.pop(context,
                                                              selected);
                                                        },
                                                        style: TextButton.styleFrom(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        12),
                                                            backgroundColor:
                                                                lightGrayColor,
                                                            minimumSize:
                                                                Size(0, 0),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            999))),
                                                        child: Text(
                                                          "선택",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelSmall,
                                                        ))
                                                  ],
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children:
                                                        _nearByPlacesList[index]
                                                            .photoUrl!
                                                            .map((photo) {
                                                      return Container(
                                                        margin: EdgeInsets.only(
                                                            right: 16),
                                                        width: 150,
                                                        height: 90,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                photo),
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
          )
        ],
      ),
    );
  }
}
