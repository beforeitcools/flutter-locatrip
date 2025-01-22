import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/editors_list_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/screen/userpage_screen.dart';

class AdvicePostScreen extends StatefulWidget {
  const AdvicePostScreen({Key? key}) : super(key: key);

  @override
  State<AdvicePostScreen> createState() => _AdvicePostScreenState();
}

class _AdvicePostScreenState extends State<AdvicePostScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isBottomSheetVisible = false;
  bool _isSelected = false;

  double? latitude;
  double? longitude;
  GoogleMapController? mapController;

  final List<Map<String, String>> adviceList = [
    {
      'author': '혼자옵서예',
      'date': '2025-02-07',
      'content':
          '제주의 자연과 지역 음식을 즐기기에 편안하고 알찬 코스네요! 이동 동선도 비교적 편리하고, 제주도의 다양한 매력을 느낄 수 있는 구성입니다 :)'
    },
    {
      'author': '혼자옵서예',
      'date': '2025-02-07',
      'content':
          '한림공원은 가족 단위나 조용히 산책하고 싶은 사람들에게 좋아요. 사진 찍기 좋은 포인트도 많아서 추억 남기기 딱이에요. 다만, 날씨가 더운 날에는 조금 더울 수 있으니 오전이나 늦은 오후 방문을 추천해요.'
    },
    {
      'author': '혼자옵서예',
      'date': '2025-02-07',
      'content':
          '현지인들도 많이 찾는 곳이라 믿고 먹을 수 있어요. 국물이 정말 시원하고 해산물이 신선해서 만족스러울 거예요. 사람이 많을 때는 조금 기다려야 할 수도 있으니 여유를 가지고 가는 게 좋아요.'
    },
    {
      'author': '혼자옵서예',
      'date': '2025-02-07',
      'content':
          '풍경을 좋아하는 분들에게 강추! 수월봉에서 바라보는 바다는 정말 평화로워요. 특히 일몰 시간에 맞춰 가면 최고의 뷰를 감상할 수 있어요. 트레킹 코스도 짧아서 부담 없이 다녀올 수 있어요.'
    },
    {
      'author': '혼자옵서예',
      'date': '2025-02-07',
      'content':
          '송악산은 경치도 좋고 트레킹하기에 부담스럽지 않아서 가벼운 산책이나 힐링 여행에 딱이에요. 바다를 끼고 걷는 코스라서 사진 찍기도 좋고, 날씨만 좋으면 멋진 풍경을 즐길 수 있을 거예요.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isBottom = _scrollController.position.pixels != 0;
        if (isBottom && !_isBottomSheetVisible && !_isSelected) {
          setState(() {
            _isBottomSheetVisible = true;
          });
          _showBottomSheet();
        }
      } else {
        if (_isBottomSheetVisible) {
          setState(() {
            _isBottomSheetVisible = false;
          });
          Navigator.of(context).pop(); // BottomSheet 닫기
        }
      }
    });

    latitude = 33.4996213;
    longitude = 126.5311884;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildVerticalDashedLine() {
    return Container(
      width: 1.5, // 점선의 너비를 고정
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 점선 시작 위치 설정
        children: List.generate(
          5, // 점선 길이 설정
          (index) => index.isEven
              ? Container(height: 4, color: grayColor)
              : Container(height: 4, color: Colors.transparent), // 점선 간격
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: pointBlueColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                      children: [
                        TextSpan(text: "나를 위한 현지인의 첨삭이 마음에 들었다면 해당 글을 "),
                        TextSpan(
                            text: "채택",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                        TextSpan(text: "해 보시는 건 어떨까요? 🥰"),
                      ])),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  _scrollController.animateTo(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
                child: Text(
                  '채택하러가기',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // BottomSheet가 닫힐 때 상태 업데이트
      setState(() {
        _isBottomSheetVisible = false;
      });
    });
  }

  void _onSelect(value) {
    setState(() {
      _isSelected = !value; // 하이라이트 활성화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '첨삭글',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
              style: TextButton.styleFrom(backgroundColor: pointBlueColor),
              onPressed: () {
                // 채택하기 기능 추가
                // 이미 채택되었으면 아무것도 하지 않음

                _onSelect(_isSelected);

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => EditorsListScreen(),
                //   ),
                // );
              },
              child: Row(
                children: [
                  _isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                      : Image.asset(
                          "assets/icon/editor_choice.png",
                          width: 20,
                          color: Colors.white,
                        ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    _isSelected ? "채택됨" : '채택하기',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
          SizedBox(
            width: 16,
          )
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 지도 섹션
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none, // 클립을 해제하여 Positioned 요소가 넘어가도 보이도록 설정
              children: [
                // 지도 섹션
                Container(
                  height: 200, // Stack의 높이를 고정
                  child: _buildMapSection(),
                ),
                // 메인 글 (지도 위에 살짝 걸치도록 Positioned 설정)
                Positioned(
                  top: 180, // 살짝 겹치는 높이 조정
                  left: 16,
                  right: 16,
                  child: Material(
                    // elevation: 5,
                    borderRadius: BorderRadius.circular(12),
                    child: _buildMainAdviceCard(adviceList[0]),
                  ),
                ),
              ],
            ),
          ),
          // 지도와 다음 Sliver 사이의 간격을 추가
          SliverToBoxAdapter(
            child: SizedBox(height: 140), // 겹친 영역에 대한 간격 확보
          ),

          // 나머지 글 섹션
          SliverToBoxAdapter(
            child: _buildSectionHeader('1', '제주 공항', '국제 공항 · 제주시'),
          ),

          // SliverToBoxAdapter(
          //   child: Center(
          //     child: SizedBox(
          //       height: 20,
          //       child: _buildVerticalDashedLine(),
          //     ),
          //   ),
          // ),

          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (context, index) {
          //       print(adviceList[index]);
          //       return _buildAdviceCard(adviceList[index + 1]);
          //     },
          //     childCount: 1,
          //   ),
          // ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('2', '한림공원', '식물원 · 제주시'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 1]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('3', '한림칼국수', '음식점 · 제주시'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 2]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('4', '수월봉', '수월봉'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 3]);
              },
              childCount: 1,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('5', '송악산', '서귀포시'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 4]);
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 지도 섹션
  Widget _buildMapSection() {
    return Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // boxShadow: [
          //   BoxShadow(
          //     color: grayColor.withOpacity(0.3),
          //     spreadRadius: 2,
          //     blurRadius: 5,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: latitude != null && longitude != null
            ? Container(
                height: 260,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(latitude! - 0.005, longitude!), zoom: 13),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller; // 지도 컨트롤러 초기화
                  },
                  /*markers: _markers,
            polylines: _polylines,*/
                  gestureRecognizers: //
                      <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                      // () => ScaleGestureRecognizer(),
                    ),
                  },
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }

  Widget _buildMainAdviceCard(Map<String, String> advice) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자, 날짜, 프로필 이미지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserpageScreen(userId: 2)),
                        );
                      },
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://www.beforeitcools.site:7777/images/user/profilePic/tangerine_3837701.png",
                          placeholder: (context, url) => SizedBox(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error_outline,
                            size: 28,
                          ),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      print("눌리니?");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserpageScreen(userId: 2)),
                      );
                    },
                    child: Text(
                      advice['author'] ?? '작성자 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                advice['date'] ?? '날짜 없음',
                style: const TextStyle(
                  fontSize: 12,
                  color: grayColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice['content']!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String number, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: pointBlueColor,
            child: Text(number,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 카드 섹션
  /// 게시글 카드 (작성자, 날짜, 프로필 이미지)
  Widget _buildAdviceCard(Map<String, String> advice) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자, 날짜, 프로필 이미지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserpageScreen(userId: 2)),
                        );
                      },
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://www.beforeitcools.site:7777/images/user/profilePic/tangerine_3837701.png",
                          placeholder: (context, url) => SizedBox(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error_outline,
                            size: 28,
                          ),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    advice['author'] ?? '작성자 없음',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                advice['date'] ?? '날짜 없음',
                style: const TextStyle(
                  fontSize: 12,
                  color: grayColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 게시글 내용
          Text(
            advice['content'] ?? '내용 없음',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
