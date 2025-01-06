import 'dart:ffi';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/place.dart';

class LocationDetailScreen extends StatefulWidget {
  final Place place;
  const LocationDetailScreen({super.key, required this.place});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  late String id;
  late String name;
  late String address;
  late String category;
  late List photoUrl;
  late LatLng location;

  int _currentIndex = 0;

  void _handlePageChange(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _showImageViewerPager(int initialPage) {
    MultiImageProvider multiImageProvider = MultiImageProvider(
      photoUrl.map((url) => NetworkImage(url)).toList(),
    );
    showImageViewerPager(
      context,
      multiImageProvider,
      onPageChanged: (newIndex) => setState(() {
        newIndex = initialPage;
        _currentIndex = newIndex;
      }),
      onViewerDismissed: (page) {
        print("Dismissed at page: $page");
      },
      // initialPage을 전달하여 시작 페이지를 지정합니다.
      // initialPage: initialPage,
    );
  }

  @override
  void initState() {
    super.initState();
    Place _place = widget.place;
    name = _place.name;
    address = _place.address;
    category = _place.category;
    photoUrl = _place.photoUrl!;
    location = _place.location;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.map_outlined)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  Icons.star_rate,
                  color: Colors.yellow,
                  size: 20,
                ),
                Text(
                  "2.0",
                  style: Theme.of(context).textTheme.titleSmall,
                )
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Text("주소", style: Theme.of(context).textTheme.labelSmall),
                SizedBox(
                  width: 8,
                ),
                Text(address,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: grayColor))
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text("전화", style: Theme.of(context).textTheme.labelSmall),
                SizedBox(
                  width: 8,
                ),
                Text("010",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: grayColor))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            if (photoUrl.isNotEmpty)
              photoUrl.length > 1
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
                              itemCount: photoUrl.length,
                              itemBuilder: (BuildContext context, int itemIndex,
                                  int pageViewIndex) {
                                return GestureDetector(
                                  onTap: () => _showImageViewerPager(
                                      itemIndex), // Trigger custom pager
                                  child: Container(
                                    child: Image.network(
                                      photoUrl[itemIndex],
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
                                '${_currentIndex + 1}/${photoUrl.length}',
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
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          photoUrl[0],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        ),
                      ),
                    )
          ],
        ),
      )),
    );
  }
}
