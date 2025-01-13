import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/map/model/location_model.dart';
import 'package:flutter_locatrip/map/model/place_api_model.dart';
import 'package:flutter_locatrip/map/model/place_detail.dart';
import 'package:flutter_locatrip/map/model/toggle_favorite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/app_overlay_controller.dart';
import '../model/place.dart';
import '../model/product_image_provider.dart';

class LocationDetailScreen extends StatefulWidget {
  final Place place;
  // final Map<String, bool> favoriteStatus;
  // final List<Map<String, bool>> favoriteStatusList;

  const LocationDetailScreen({
    super.key,
    required this.place,
    // required this.favoriteStatus,
    // required this.favoriteStatusList
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  final PlaceApiModel _placeApiModel = PlaceApiModel();
  final LocationModel _locationModel = LocationModel();
  final ToggleFavorite _toggleFavorite = ToggleFavorite();

  int _currentIndex = 0;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  late Place _place;
  PlaceDetail? _placeDetail;
  bool _isLoading = false;
  // bool _isFavorite = false;

  bool _isExpanded = false;

  // Map<String, bool> _favoriteStatus = {};
  // List<Map<String, bool>> _favoriteStatusList = [];
  bool _isFavorite = false;

  void _handlePageChange(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _showImageViewerPager(int initialPage, List<String> photoUrl) {
    ProductsImageProvider productsImageProvider =
        ProductsImageProvider(photoUrl: photoUrl, initialIndex: initialPage);
    carouselController.jumpToPage(initialPage);

    showImageViewerPager(
      context,
      productsImageProvider,
      onPageChanged: (newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
        carouselController.jumpToPage(newIndex);
      },
      onViewerDismissed: (page) {
        setState(() {
          _currentIndex = page;
        });
        carouselController.jumpToPage(page);
      },
    );

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _currentIndex = initialPage;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _place = widget.place;
    _loadDetail(_place.id);
    setState(() {
      AppOverlayController.removeOverlay();
      // _favoriteStatusList = widget.favoriteStatusList;
      // _favoriteStatus = widget.favoriteStatus;
      // print('_favoriteStatus $_favoriteStatus');
    });
  }

  void _loadDetail(String id) async {
    try {
      Map<String, dynamic> placeDetail =
          await _placeApiModel.getPlaceDetail(id);
      print('placeDetail $placeDetail');

      if (placeDetail.isNotEmpty) {
        List<dynamic> photos = placeDetail['photos'] ?? [];
        List<String> photoUrls = [];
        for (var photo in photos) {
          String? photoUri = photo['name'];
          if (photoUri != null) {
            photoUrls.add(photoUri);
          }
        }

        // 병렬로 사진 가져오기
        List<String> photoUris = await _placeApiModel.getPlacePhotos(photoUrls);
        _place.photoUrl = photoUris.isNotEmpty ? photoUris : null;

        setState(() {
          _placeDetail = PlaceDetail(
            place: _place,
            phone: placeDetail["internationalPhoneNumber"] ?? "",
            rating: placeDetail["rating"] != null
                ? (placeDetail["rating"] as num).toDouble()
                : 0.0,
            reviews: placeDetail["reviews"] ?? [],
            googleMapsUri: placeDetail["googleMapsUri"] ?? "",
          );
          _isLoading = false;
        });
        _syncFavoriteStatus(widget.place.name);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("에러메시지 : $e");
    }
  }

  void _launchMap(String googleMapsUrl) async {
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _syncFavoriteStatus(String locationName) async {
    try {
      Map<String, bool>? result = await _locationModel
          .fetchSpecificFavoriteStatusFromServer(locationName, context);
      print('result $result');
      if (result != null) {
        setState(() {
          _isFavorite = result[locationName]!;
          // _favoriteStatus[locationName] = result[locationName]!;
        });
      }
    } catch (e) {
      print('에러메시지 $e');
    }
  }

  void _updateFavoriteStatus(bool isFavorite, Place place) {
    // print('누른 후 isFavorite $isFavorite');
    setState(() {
      // _favoriteStatus[place.name] = isFavorite;
      // print('_favoriteStatus[place.name] ${_favoriteStatus[place.name]}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              print('this $_isFavorite');
              Navigator.pop(context, _isFavorite);
            },
            icon: Icon(Icons.arrow_back)),
        actions: [
          _placeDetail?.googleMapsUri != null
              ? IconButton(
                  onPressed: () {
                    _launchMap(_placeDetail!.googleMapsUri);
                  },
                  icon: Icon(Icons.map_outlined))
              : SizedBox.shrink(),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setStateModal) {
                        // bool isFavorite =
                        //     _favoriteStatus[_placeDetail?.place.name] ?? false;
                        return Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min, // 컨텐츠 높이에 맞게 조정
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // _toggleFavoriteStatus(_placeDetail!.place);
                                      _toggleFavorite.toggleFavoriteStatus(
                                          _placeDetail!.place,
                                          _isFavorite,
                                          // _favoriteStatusList,
                                          context, () {
                                        /* _updateFavoriteStatus(
                                            !(_favoriteStatus[
                                                _placeDetail?.place.name]!),
                                            _placeDetail!.place);*/

                                        // Modal 내부 setState 호출
                                        setStateModal(() {
                                          _isFavorite = !_isFavorite;
                                        });
                                        // 부모 위젯의 상태도 업데이트
                                        /* setState(() {
                                          _favoriteStatus[_placeDetail!
                                              .place.name] = isFavorite;
                                        });*/
                                      });
                                      // _toggleFavoriteStatus(_placeDetail!.place);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _isFavorite
                                            ? Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 20,
                                              )
                                            : Icon(
                                                Icons.favorite_outline_outlined,
                                                color: blackColor,
                                                size: 20,
                                              ),
                                        SizedBox(width: 15),
                                        Text(_isFavorite ? "저장 취소" : "장소 저장",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: lightGrayColor,
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 20,
                                          color: blackColor,
                                        ),
                                        SizedBox(width: 15),
                                        Text("일정 추가",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: lightGrayColor,
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.ios_share,
                                          size: 20,
                                          color: blackColor,
                                        ),
                                        SizedBox(width: 15),
                                        Text("장소 공유",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: lightGrayColor,
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
                                ]));
                      });
                    });
              },
              icon: Icon(Icons.more_vert))
        ],
      ),
      body: _isLoading || _placeDetail == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _placeDetail!.place.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _placeDetail?.rating == 0.0
                      ? SizedBox.shrink()
                      : Row(
                          children: [
                            Icon(
                              Icons.star_rate,
                              color: Colors.yellow,
                              size: 20,
                            ),
                            Text(
                              _placeDetail!.rating.toString(),
                              style: Theme.of(context).textTheme.titleSmall,
                            )
                          ],
                        ),
                  SizedBox(
                    height: 12,
                  ),
                  _placeDetail?.place.address == ""
                      ? SizedBox.shrink()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("주소",
                                style: Theme.of(context).textTheme.labelSmall),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Text(
                              _placeDetail!.place.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: grayColor),
                              softWrap: true,
                            ))
                          ],
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  _placeDetail?.phone == ""
                      ? SizedBox.shrink()
                      : Row(
                          children: [
                            Text("전화",
                                style: Theme.of(context).textTheme.labelSmall),
                            SizedBox(
                              width: 8,
                            ),
                            Text(_placeDetail!.phone,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: grayColor))
                          ],
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  // 사진
                  if (_placeDetail!.place.photoUrl!.isNotEmpty)
                    _placeDetail!.place.photoUrl!.length > 1
                        ? Stack(
                            children: [
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CarouselSlider.builder(
                                    itemCount:
                                        _placeDetail?.place.photoUrl!.length,
                                    carouselController: carouselController,
                                    itemBuilder: (BuildContext context,
                                        int itemIndex, int pageViewIndex) {
                                      List? photoUrl =
                                          _placeDetail?.place.photoUrl;
                                      return GestureDetector(
                                        onTap: () => _showImageViewerPager(
                                            itemIndex,
                                            photoUrl as List<
                                                String>), // Trigger custom pager
                                        child: Container(
                                          child: Image.network(
                                            photoUrl![itemIndex],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      );
                                    },
                                    options: CarouselOptions(
                                      initialPage: _currentIndex,
                                      viewportFraction: 1.0,
                                      onPageChanged: (index, reason) {
                                        _handlePageChange(index);
                                      },
                                      scrollDirection: Axis.horizontal,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(7, 0, 7, 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                      '${_currentIndex + 1}/${_placeDetail?.place.photoUrl!.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.8)),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _placeDetail?.place.photoUrl![0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                              ),
                            ),
                          ),
                  if (_placeDetail!.reviews.isNotEmpty)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text("리뷰",
                            style: Theme.of(context).textTheme.titleMedium),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            // physics: BouncingScrollPhysics(),
                            itemCount: _placeDetail?.reviews.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: lightGrayColor,
                                  width: _placeDetail?.reviews.length ==
                                          (index + 1)
                                      ? 0
                                      : 1,
                                ))),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      margin: EdgeInsets.only(right: 14),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: _placeDetail?.reviews?[index]
                                                            ?[
                                                            "authorAttribution"]
                                                        ?["photoUri"] !=
                                                    null
                                                ? NetworkImage(
                                                    _placeDetail!
                                                                .reviews![index]
                                                            [
                                                            "authorAttribution"]
                                                        ["photoUri"],
                                                  )
                                                : AssetImage(
                                                        'assets/default_profile_image.png')
                                                    as ImageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (_placeDetail?.reviews[index]
                                                ["rating"] !=
                                            null)
                                          Row(
                                            children: List.generate(
                                              _placeDetail?.reviews[index][
                                                  "rating"], // 별 개수를 rating에서 가져옴
                                              (starIndex) {
                                                return Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                  size: 14,
                                                );
                                              },
                                            ),
                                          ),
                                        Text(
                                          _placeDetail?.reviews[index]
                                                      ["authorAttribution"]
                                                  ["displayName"] ??
                                              "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: grayColor),
                                          softWrap: true,
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            alignment: Alignment.centerLeft,
                                            child: _placeDetail?.reviews[index]
                                                        ["originalText"] !=
                                                    null
                                                ? Column(children: [
                                                    Text(
                                                      _placeDetail?.reviews[
                                                                      index][
                                                                  "originalText"]
                                                              ["text"] ??
                                                          "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall,

                                                      /*maxLines: _isExpanded
                                                          ? null
                                                          : 3,
                                                      overflow: _isExpanded
                                                          ? TextOverflow.visible
                                                          : TextOverflow
                                                              .ellipsis,*/
                                                      softWrap: true,
                                                    ),
                                                    /*!_isExpanded
                                                        ? TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _isExpanded =
                                                                    true;
                                                              });
                                                            },
                                                            child: Text("더보기"),
                                                          )
                                                        : SizedBox.shrink(),*/
                                                  ])
                                                : SizedBox.shrink())
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            })
                      ],
                    )
                ],
              ),
            )),
    );
  }
}
