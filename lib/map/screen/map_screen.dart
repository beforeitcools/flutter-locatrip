import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../checklist/widget/checklist_widget.dart';
import '../../common/widget/color.dart';
import '../../trip/model/current_position_model.dart';
import '../../trip/widget/denied_permission_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final ScrollController _categoryScrollController = ScrollController();

  TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;

  final double maxSize = 0.9;
  final double minSize = 0.48;
  final double tolerance = 0.001;

  bool isExpanded = false;

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
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoading = false;
      });
      _moveMapToCurrentLocation();
    } catch (e) {
      _showPermissionDialog();
    }
  }

  void _moveMapToCurrentLocation() {
    if (latitude != null && longitude != null && mapController != null) {
      // print("latitude2: $latitude longitude: $longitude");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        latitude != null && longitude != null
            ? Container(
                height: 460,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(latitude!, longitude!), zoom: 15),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                ),
              )
            : Center(child: CircularProgressIndicator()),
        Padding(
            padding: EdgeInsets.only(top: 370),
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                  onPressed: () {},
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
