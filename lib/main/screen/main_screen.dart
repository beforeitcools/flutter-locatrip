import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/main/model/main_model.dart';
import 'package:flutter_locatrip/map/screen/map_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/trip/model/recommend_region.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';

import 'package:flutter_locatrip/trip/model/trip_user_model.dart';
import 'package:flutter_locatrip/trip/screen/first_trip_screen.dart';
import 'package:flutter_locatrip/trip/screen/trip_view_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../trip/model/invite_state.dart';
import '../model/main_screen_provider.dart';
import '../widget/header_delegate.dart';
import '../widget/sort_bottom_sheet.dart';

class MainScreen extends StatefulWidget {
  final Function(int, String) onTapped;
  const MainScreen({super.key, required this.onTapped});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TripUserModel _tripUserModel = TripUserModel();
  final TripModel _tripModel = TripModel();
  final MainModel _mainModel = MainModel();
  final MypageModel _mypageModel = MypageModel();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _customScrollController = ScrollController();

  bool _isLoading = true;
  bool _unreadAlarmExists = false;

  int? _inviteId;
  int? _hostId;

  late String _profilePic;
  late String _hostNickName;
  late String _nickName;

  double _animatedPositionedOffset = 0;
  bool _isTop = false;
  List<dynamic> _myTripList = [];
  bool _isTripLoading = true;

  late String _selectedRegion;
  late String _dateRange;

  bool _isShowCancel = false;

  late String _regionImage;

  @override
  void initState() {
    super.initState();

    _inviteId = Provider.of<InviteState>(context, listen: false).inviteId;
    _hostId = Provider.of<InviteState>(context, listen: false).hostId;

    // 일정에 참여중인 유저인지 확인
    if (_inviteId != null && _hostId != null) {
      _isExistTripUser();
    }
    loadData();
    _customScrollController.addListener(() {
      setState(() {
        _animatedPositionedOffset = _customScrollController.offset;

        if (_animatedPositionedOffset > 80) {
          _isTop = true;
        } else {
          _isTop = false;
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider를 통해 상태를 감지하고 loadInfo 실행
    final provider = Provider.of<MainScreenProvider>(context);
    if (provider.shouldReload) {
      print('provider!!!');
      setState(() {
        _isTripLoading = true;
      });
      _myTripList.clear();
      _getMyTrip();
      provider.resetReload(); // 상태 초기화
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customScrollController.dispose();

    super.dispose();
  }

  void loadData() async {
    // 유저정보 가져오기 / 알림여부
    await _getUserInfo();
    // 일정 가져오기
    await _getMyTrip();
  }

  // 호스트 정보 불러오기
  _getHostUserInfo() async {
    try {
      Map<String, dynamic> result =
          await _mainModel.getHostUserInfo(context, _hostId!);

      if (result.isNotEmpty) {
        setState(() {
          _profilePic =
              result["profilePic"] != null ? result["profilePic"] : "null";
          _hostNickName = result["users"]["nickname"];
        });
      }
    } catch (e) {
      print('에러메시지?? $e');
    }
  }

  // 일정 가져오기
  _getMyTrip() async {
    try {
      Map<String, dynamic> result = await _mypageModel.getMyTripData(context);
      if (result.isNotEmpty) {
        _myTripList.addAll(result["futureTrips"]);
        print('_myTrip$_myTripList');
        setState(() {
          _isTripLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isTripLoading = false;
      });
      print('일정가져오는 에러메시지 $e');
    }
  }

  // 현재 로그인된 사용자 정보
  _getUserInfo() async {
    try {
      Map<String, dynamic> result = await _mypageModel.getMyPageData(context);
      // print('reulst $result');
      if (result.isNotEmpty) {
        setState(() {
          _nickName = result["user"]["nickname"];
          _isLoading = false;
          _unreadAlarmExists = result["unreadAlarmExists"];
        });
      }
    } catch (e) {
      _isLoading = false;
      print('로그인사용자 에러메시지 $e');
    }
  }

  void _isExistTripUser() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final dynamic stringId = await _storage.read(key: 'userId');
    var userId = int.tryParse(stringId) ?? 0; // 초대받은 사용자

    // 초대받은 사용자와 호스트 비교
    if (userId == _hostId) {
      showExistsModal(context);
      return;
    }

    Map<String, dynamic> data = {"tripId": _inviteId, "userId": userId};

    try {
      bool isExistTripUser =
          await _tripUserModel.isExistTripUser(context, data);

      if (isExistTripUser) {
        showExistsModal(context);
      } else {
        showInviteModal(context, _inviteId!);
      }
    } catch (e) {
      print('에러메시지 $e');
    }
  }

  // 수락하면 트립유저에 저장
  void _saveTripUser() async {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final dynamic stringId = await _storage.read(key: 'userId');
    int userId = int.tryParse(stringId) ?? 0;

    Map<String, dynamic> data = {"tripId": _inviteId, "userId": userId};
    try {
      Map<String, dynamic> saveResult =
          await _tripUserModel.saveTripUser(context, data);

      if (saveResult.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TripViewScreen(tripId: saveResult["tripId"])));
      }
    } catch (e) {
      print('에러메시지 $e');
    }
  }

  // 초대 모달
  void showInviteModal(BuildContext context, int inviteId) async {
    try {
      Map<String, dynamic> tripInfoMap =
          await _tripModel.selectTrip(inviteId, context);
      // print('tripInfoMap $tripInfoMap');
      await _getHostUserInfo();

      if (tripInfoMap.isNotEmpty) {
        if (_profilePic.isNotEmpty && _hostNickName.isNotEmpty) {
          String defaultImageUrl = "assets/default_profile_image.png";
          _profilePic == "null" ? defaultImageUrl : _profilePic;
          String region = tripInfoMap["trip"]["selectedRegions"][0]["region"];
          int regionLength = tripInfoMap["trip"]["selectedRegions"].length - 1;
          String elseString = regionLength > 0 ? " 외 $regionLength개 도시" : "";
          String startDate = tripInfoMap["trip"]["startDate"];
          String endDate = tripInfoMap["trip"]["endDate"];
          String dateRange =
              startDate == endDate ? startDate : "$startDate - $endDate";

          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 16),
                    title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Image.asset(
                              _profilePic.toString() ?? defaultImageUrl,
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
                          ),
                          SizedBox(height: 15),
                          FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Text(
                              '$region$elseString 여행',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            dateRange,
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ]),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$_hostNickName님이 여행에 초대했어요.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: grayColor),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "초대를 수락하고 함께 즐거운 여행을 계획해보세요.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: grayColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actionsPadding: EdgeInsets.only(bottom: 16),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      // 닫기 버튼
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: grayColor,
                                  fontWeight: FontWeight.w500),
                        ),
                      ),
                      // 수락하기 버튼
                      TextButton(
                        onPressed: () {
                          _saveTripUser();
                          Provider.of<InviteState>(context, listen: false)
                              .setInviteId(null);
                          // 모달 닫기
                          Navigator.pop(context);
                        },
                        child: Text(
                          '초대수락',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: pointBlueColor,
                                  fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ));
        }
      }
    } catch (e) {
      print('에러메시지! $e');
    }
  }

  // 이미 일정에 참여 중 일 때
  void showExistsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(30),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        actionsPadding: EdgeInsets.only(bottom: 10),
        content: Text(
          '이미 참여하고 있는 여행입니다.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // 닫기 버튼
          TextButton(
            onPressed: () {
              Provider.of<InviteState>(context, listen: false)
                  .setInviteId(null);
              Navigator.pop(context);
            },
            child: Text(
              '확인',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: pointBlueColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 정렬하기
  void sortTrips(String sortBy) {
    if (sortBy == 'startDate') {
      setState(() {
        _myTripList.sort((a, b) {
          String startDateA = a['startDate'];
          String startDateB = b['startDate'];
          return startDateA.compareTo(startDateB);
        });
      });
    } else if (sortBy == 'title') {
      setState(() {
        _myTripList.sort((a, b) {
          String titleA = a['title'];
          String titleB = b['title'];
          return titleA.compareTo(titleB);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned(
            top: -_animatedPositionedOffset,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 340,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/bg/bg-1.jpg'),
                  ),
                ),
              ),
            ),
          ),

          // 스크롤 가능한 내용
          CustomScrollView(
            controller: _customScrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: HeaderDelegate(
                  child: Container(
                    color: _isTop ? Colors.white : Colors.transparent,
                    padding: EdgeInsets.fromLTRB(16, 40, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _isLoading
                            ? SizedBox.shrink()
                            : Expanded(
                                child: Text(
                                  "여행자, ${_nickName}님!",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color:
                                            _isTop ? blackColor : Colors.white,
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                              ),
                        IconButton(
                          onPressed: () {},
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.notifications_outlined,
                                  color: _isTop ? blackColor : Colors.white),
                              if (_unreadAlarmExists)
                                Positioned(
                                  right: -1,
                                  top: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) {
                            widget.onTapped(1, value);
                          },
                          onChanged: (value) {
                            if (value.length > 0) {
                              setState(() {
                                _isShowCancel = true;
                              });
                            } else {
                              setState(() {
                                _isShowCancel = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            prefixIconConstraints: BoxConstraints(minWidth: 40),
                            prefixIcon: Padding(
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  Icons.search,
                                  size: 18,
                                  color: grayColor,
                                )),
                            hintText: "어디로 떠나시나요?",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    color: grayColor,
                                    fontWeight: FontWeight.w300),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _isShowCancel
                                ? IconButton(
                                    icon: Icon(
                                      Icons.cancel,
                                      color: grayColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _isShowCancel = false;
                                      });
                                    },
                                  )
                                : SizedBox.shrink(),
                          ),
                        )),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...mainRegions.map((region) {
                              int index = mainRegions.indexOf(region);

                              return Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TextButton(
                                      onPressed: () {
                                        widget.onTapped(1, "${region['name']}");
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.zero),
                                      child: Text(
                                        "${region['emoji']} ${region['name']}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      )));
                            })
                          ],
                        )),
                    SizedBox(height: 140),
                    Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 80),
                        child: Column(children: [
                          SizedBox(
                            child: _myTripList.isNotEmpty
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("내 여행",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700)),
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    SortBottomSheet(
                                                        sortTrips: sortTrips));
                                          },
                                          icon: Icon(
                                            Icons.swap_vert_rounded,
                                            color: grayColor,
                                          ))
                                    ],
                                  )
                                : SizedBox.shrink(),
                            height: 30,
                          ),
                          _isTripLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _myTripList.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true, // 부모 위젯 크기에 맞춤
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: _myTripList.length,
                                      itemBuilder: (context, i) {
                                        if (_myTripList.isNotEmpty) {
                                          String startDate =
                                              _myTripList[i]["startDate"];
                                          String endDate =
                                              _myTripList[i]["endDate"];

                                          _dateRange = startDate == endDate
                                              ? startDate
                                              : "$startDate ~ $endDate";
                                        }
                                        List selectedRegionList = _myTripList[i]
                                            ["selectedRegionsList"];
                                        if (selectedRegionList.length > 1) {
                                          for (int i = 0;
                                              i < selectedRegionList.length;
                                              i++) {
                                            if (i > 0) {
                                              _selectedRegion +=
                                                  " ${selectedRegionList[i]}";
                                            } else {
                                              _selectedRegion =
                                                  selectedRegionList[i];
                                            }
                                          }
                                        } else {
                                          _selectedRegion = _myTripList[i]
                                              ["selectedRegionsList"][0];
                                        }
                                        if (regionImages[
                                                selectedRegionList[0]] !=
                                            null) {
                                          _regionImage =
                                              "${regionImages[selectedRegionList[0]]}";
                                        } else {
                                          _regionImage =
                                              "assets/images/default.jpg";
                                        }

                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TripViewScreen(
                                                              tripId: _myTripList[
                                                                      i]
                                                                  ["tripId"])));
                                            },
                                            child: Container(
                                                height: 150,
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Stack(children: [
                                                  // 배경 이미지
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.asset(
                                                      _regionImage,
                                                      fit: BoxFit.cover,
                                                      height: double.infinity,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                  // 딤 효과 (반투명 레이어)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(16),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        FractionallySizedBox(
                                                          widthFactor: 1,
                                                          child: Text(
                                                            _myTripList[i]
                                                                ["title"],
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                            softWrap: true,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 3,
                                                        ),
                                                        FractionallySizedBox(
                                                            widthFactor: 1,
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on_outlined,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  _selectedRegion,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelSmall
                                                                      ?.copyWith(
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                                Text(
                                                                  " · ",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelSmall
                                                                      ?.copyWith(
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                                Text(
                                                                  _dateRange,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelSmall
                                                                      ?.copyWith(
                                                                          color:
                                                                              Colors.white),
                                                                )
                                                              ],
                                                            ))
                                                      ],
                                                    ),
                                                  )
                                                ])));
                                      })
                                  : Padding(
                                      padding: EdgeInsets.only(top: 60),
                                      child: Column(
                                        children: [
                                          Text(
                                            "생성된 여행이 없습니다.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TripScreen(),
                                                      // fullscreenDialog: true,
                                                    ));
                                              },
                                              child: Text(
                                                "여행 추가",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                        color: pointBlueColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ))
                                        ],
                                      ),
                                    )
                        ]))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 68,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripScreen(),
                  // fullscreenDialog: true,
                ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
              ),
              Text(
                "일정생성",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
