import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/advice_post_screen.dart';
import 'package:flutter_locatrip/advice/widget/dotted_line.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';

import '../model/advice_model.dart';

class AdviceViewScreen extends StatefulWidget {
  final int postId;
  final int tripDayLocationId;

  const AdviceViewScreen(
      {super.key, required this.postId, required this.tripDayLocationId});

  @override
  State<AdviceViewScreen> createState() => _AdviceViewScreenState();
}

class _AdviceViewScreenState extends State<AdviceViewScreen> {
  bool _isLoading = true;
  final AdviceModel _adviceModel = AdviceModel();
  late int _postId;
  late int _tripDayLocationId;
  late String _locationName;
  late String _locationAddress;
  late String _locationCategory;
  late int _orderIndex;
  late List<dynamic> _adviceList;

  Future<void> _loadMyAdviceData(int postId, int tripDayLocationId) async {
    try {
      LoadingOverlay.show(context);
      Map<String, Object> postIdAndLocattionIdDTO = {
        "postId": postId,
        "locationId": tripDayLocationId
      };
      Map<String, dynamic> result =
          await _adviceModel.getAdviceData(context, postIdAndLocattionIdDTO);
      print("result: $result");
      setState(() {
        if (tripDayLocationId != 0) {
          _locationName = result['locationName'];
          _locationAddress = result['locationAddress'];
          _locationCategory = result['locationCategory'];
          _orderIndex = result['orderIndex'];
        } else {
          _locationName = '';
          _locationAddress = '';
          _locationCategory = '';
          _orderIndex = 0;
        }
        _adviceList = result['adviceList'];
        print("locationName: $_locationName");
        print(_locationAddress);
        print(_locationCategory);
        print(_orderIndex);
        print("adviceList: $_adviceList");
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!첨삭 로드 중 에러 발생 : $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
    _tripDayLocationId = widget.tripDayLocationId;
    _loadMyAdviceData(_postId, _tripDayLocationId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '첨삭보기',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 점선
          /*Positioned(
            left: 210, // 점선 위치 조정
            top: 75, // 헤더의 대략적 높이에서 시작 (고정값)
            bottom: 0, // 하단 끝까지 점선
            child: Container(
              width: 1,
              color: Colors.transparent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight;
                  return Column(
                    children: List.generate(
                      (totalHeight / 8).floor(),
                      (i) => i.isEven
                          ? Container(height: 4, color: grayColor)
                          : Container(height: 4, color: Colors.transparent),
                    ),
                  );
                },
              ),
            ),
          ),*/

          // 콘텐츠
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(), // 헤더
              Expanded(child: _buildAdviceList()), // 리스트
            ],
          ),
        ],
      ),
    );
  }

  // 헤더 영역
  Widget _buildHeader() {
    return Stack(
      children: [
        _tripDayLocationId != 0
            // 헤더 콘텐츠
            ? Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: pointBlueColor,
                      child: Text(
                        '$_orderIndex',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _locationName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$_locationCategory · $_locationAddress',
                              style: TextStyle(
                                fontSize: 12,
                                color: grayColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              )
            : Container(
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    Text("전체 첨삭")
                  ],
                ),
              ),
      ],
    );
  }

  // 게시글 리스트 영역
  Widget _buildAdviceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _adviceList.length,
      itemBuilder: (context, index) {
        final advice = _adviceList[index];
        return Stack(
          children: [
            // Dotted line
            if (index != 0)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: DottedLine(
                    height: 50,
                    color: grayColor,
                    dotWidth: 2.0,
                    dotHeight: 3.0,
                    spacing: 2.0,
                  ),
                ),
              ),

            _buildAdviceCard(
                localAdviceId: advice['localAdviceId'] as int,
                contents: advice['contents'] as String,
                userId: advice['userId'] as int,
                profilePic: advice['profilePic'] ?? '',
                nickname: advice['nickname'] as String,
                createdAt: advice['createdAt'] as String),
          ],
        );
      },
    );
  }

  // 첨삭 카드 섹션
  Widget _buildAdviceCard(
      {required int localAdviceId,
      required String contents,
      required int userId,
      required String profilePic,
      required String nickname,
      required String createdAt}) {
    return Column(
      children: [
        SizedBox(
          height: 26,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6),
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              Row(
                children: [
                  profilePic.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profilePic,
                            placeholder: (context, url) => SizedBox(
                              width: 15,
                              height: 15,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error_outline,
                              size: 10,
                            ),
                            fit: BoxFit.cover,
                            width: 20,
                            height: 20,
                          ),
                        )
                      : CircleAvatar(
                          radius: 10,
                          backgroundImage:
                              AssetImage('assets/default_profile_image.png')
                                  as ImageProvider),
                  SizedBox(width: 8),
                  Text(
                    nickname,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(width: 8),
                  Text(
                    createdAt,
                    style: const TextStyle(fontSize: 12, color: grayColor),
                  ),
                  Spacer(),
                  // 로그인 된 사용자의 id와 비교해서 보여줄지 말지
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // 수정/ 삭제
                      _showOptions(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                contents,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                // maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 더보기 메뉴
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('첨삭글보기'),
                onTap: () {
                  Navigator.pop(context); // 바텀시트 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdvicePostScreen(), // AdvicePostScreen으로 이동
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
