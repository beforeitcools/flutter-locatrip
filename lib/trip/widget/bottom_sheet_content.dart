import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/region_model.dart';
import 'package:flutter_locatrip/trip/widget/no_result.dart';
import 'package:flutter_locatrip/trip/widget/selected_regions.dart';

import '../screen/create_trip_screen.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final RegionModel _regionModel = RegionModel();

  // 검색 컨트롤러
  TextEditingController _searchController = TextEditingController();

  // 우리나라 시군
  List<Map<String, String>> _allRegionsList = [];

  // 추천 장소들 - 나중에 이미지 추가할 때 변경하기
  List<Map<String, String>> _recommendedRegions = [];
  List _recommendedNames = [
    "가평",
    "양평",
    "강릉",
    "속초",
    "경주",
    "부산",
    "여수",
    "인천",
    "전주",
    "제주",
    "춘천",
    "홍천",
    "태안",
    "통영",
    "거제",
    "남해",
    "포항",
    "안동"
  ];

  Map<String, String> regionImages = {
    "가평": "assets/images/gapyeong.jpg",
    "양평": "assets/images/yangpyeong.jpg",
    "강릉": "assets/images/gangneung.jpg",
    "속초": "assets/images/sokcho.jpg",
    "경주": "assets/images/gyeongju.jpg",
    "부산": "assets/images/busan.jpg",
    "여수": "assets/images/yeosu.jpg",
    "인천": "assets/images/incheon.jpg",
    "전주": "assets/images/jeonju.jpg",
    "제주": "assets/images/jeju.jpg",
    "춘천": "assets/images/chuncheon.jpg",
    "홍천": "assets/images/hongcheon.jpg",
    "태안": "assets/images/taean.jpg",
    "통영": "assets/images/tongyeong.jpg",
    "거제": "assets/images/geoje.jpg",
    "남해": "assets/images/namhae.jpg",
    "포항": "assets/images/pohang.jpg",
    "안동": "assets/images/andong.jpg"
  };

  // 기본 이미지 (이미지가 없는 경우)
  final String defaultImageUrl = "assets/imgPlaceholder.png";

  // 검색결과 리스트
  List<Map<String, String>> _displayedRegions = [];

  // 선택된 지역 리스트
  List<Map<String, String>> selectedRegions = [];

  bool isAbled = false;
  bool isLoading = true;
  bool isNoResult = false;

  // 전체 시군 가져오기
  void _loadRegions() async {
    List<Map<String, String>> _allRegions =
        await _regionModel.searchAllRegions();
    setState(() {
      _allRegionsList = _allRegions;

      // 추천 지역 필터링
      _recommendedRegions = List<Map<String, String>>.from(_allRegionsList
          .where((region) => _recommendedNames.contains(region['name']))
          .map((region) => {
                ...region,
                "imageUrl": regionImages[region['name']] ?? defaultImageUrl,
              }));

      // // '국내' 추가
      // _recommendedRegions.add({
      //   "name": "국내",
      //   "sub": "어디론가 떠나고 싶을 때",
      //   "image": "",
      // });

      // 초기 화면에서 추천 지역 표시
      _displayedRegions = _recommendedRegions;
      isLoading = false;
      print(isLoading);
    });
  }

// 검색 필터링 로직
  void _filterRegions(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedRegions = _recommendedRegions;
        isNoResult = false;
      } else {
        _displayedRegions = _allRegionsList
            .where((region) =>
                region['name']!.contains(query) ||
                region['sub']!.contains(query))
            .toList();

        isNoResult = _displayedRegions.isEmpty;
      }
    });
  }

  // 버튼 텍스트 업데이트 (선택/취소)
  String getButtonText(String region) {
    return selectedRegions.any((item) => item['name'] == region) ? "취소" : "선택";
  }

// 지역 선택/해제 메서드
  void _toggleRegion(String region, String imageUrl) {
    setState(() {
      bool exists = selectedRegions.any((item) => item['name'] == region);

      if (exists) {
        selectedRegions.removeWhere((item) => item['name'] == region);
      } else {
        selectedRegions.add({"name": region, "imageUrl": imageUrl});
      }
      isAbled = selectedRegions.isNotEmpty;
    });
  }

// 버튼 스타일 설정
  ButtonStyle _toggleStyle(String regionName) {
    bool isSelected = selectedRegions.any((item) => item['name'] == regionName);
    return TextButton.styleFrom(
      backgroundColor: isSelected ? Colors.white : lightGrayColor,
      side: BorderSide(
        color: isSelected ? pointBlueColor : Colors.transparent,
      ),
      foregroundColor: isSelected ? pointBlueColor : blackColor,
      textStyle: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center, // 텍스트 중앙 정렬
                  child: Text(
                    "장소검색",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 20),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          TextField(
            controller: _searchController,
            onChanged: _filterRegions,
            decoration: InputDecoration(
              hintText: "여행, 어디로 떠나시나요?",
              filled: true,
              fillColor: lightGrayColor,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                          _filterRegions('');
                          setState(() {
                            isNoResult = false;
                          });
                        },
                      ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isNoResult = true;
                          });
                          // if(_searchController.text.isEmpty)
                        },
                        icon: Icon(Icons.search))
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: isNoResult
                      ? NoResult()
                      : ListView.builder(
                          itemCount: _displayedRegions.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              // contentPadding: EdgeInsets.only(bottom: 20),
                              leading: Image.asset(
                                _displayedRegions[i]["imageUrl"] ?? "",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    defaultImageUrl,
                                    width: 50,
                                    height: 50,
                                  );
                                },
                              ),
                              contentPadding: EdgeInsets.zero,
                              title: Text(_displayedRegions[i]["name"]!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w500)),
                              subtitle: Text(_displayedRegions[i]["sub"]!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: grayColor)),
                              trailing: TextButton(
                                onPressed: () {
                                  _toggleRegion(
                                      _displayedRegions[i]['name'].toString(),
                                      _displayedRegions[i]['imageUrl']
                                          .toString());
                                },
                                child: Text(
                                  getButtonText(
                                      _displayedRegions[i]['name'].toString()),
                                ),
                                style: _toggleStyle(
                                    _displayedRegions[i]['name'].toString()),
                              ),
                            );
                          })),
          Container(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: lightGrayColor,
                      width: 1.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(0, -10),
                      blurRadius: 14,
                    ),
                  ]),
              child: Column(
                children: [
                  Row(
                    children: [
                      ...selectedRegions.map((region) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
                          child: Column(
                            children: [
                              //image 위에 x버튼
                              Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12), // 이미지 둥글게
                                      child: Image.asset(
                                        region["imageUrl"].toString() ??
                                            defaultImageUrl,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            defaultImageUrl,
                                            width: 50,
                                            height: 50,
                                          );
                                        },
                                      )),
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              offset: Offset(1, 0),
                                              blurRadius: 2,
                                            )
                                          ],
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.close,
                                              size: 12, color: grayColor),
                                          onPressed: () {
                                            setState(() {
                                              selectedRegions.remove(region);
                                              if (selectedRegions.isEmpty)
                                                isAbled = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                region["name"].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: grayColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity, // 너비 100%
                    child: TextButton(
                      onPressed: isAbled
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateTripScreen(
                                        selectedRegions: selectedRegions,
                                        defaultImageUrl: defaultImageUrl,
                                        isAbled: isAbled),
                                    fullscreenDialog: true,
                                  ));
                            }
                          : null,
                      style: TextButton.styleFrom(
                        minimumSize: Size(100, 56), // 최소 높이 설정
                        backgroundColor:
                            isAbled ? pointBlueColor : lightGrayColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 둥근 테두리 설정
                        ),
                      ),
                      child: Text(
                        selectedRegions.isEmpty
                            ? "최소 1개 도시 선택"
                            : "${selectedRegions[0]["name"].toString()}" +
                                ((selectedRegions.length - 1) != 0
                                    ? " 외 ${(selectedRegions.length - 1).toString()}개 선택 완료"
                                    : " 선택 완료"),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
