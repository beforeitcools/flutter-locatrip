import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/model/advice_model.dart';
import 'package:flutter_locatrip/advice/screen/advice_post_screen.dart';
import 'package:flutter_locatrip/advice/screen/advice_view_screen.dart';
import 'package:flutter_locatrip/advice/screen/post_view_screen.dart';
import 'package:flutter_locatrip/advice/widget/post_bottom_sheet.dart';
import 'package:flutter_locatrip/advice/widget/post_filter.dart';
import 'package:flutter_locatrip/advice/widget/post_list.dart';
import 'package:flutter_locatrip/advice/widget/recommendations.dart';
import 'package:flutter_locatrip/advice/widget/shortage_dialog.dart';
import 'package:flutter_locatrip/common/screen/alarm_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/screen/local_area_auth_screen.dart';
import 'package:flutter_locatrip/mypage/widget/custom_dialog.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreen();
}

class _PostListScreen extends State<PostListScreen> {
  bool _isLoading = true;
  late String _localArea = '';
  late bool _unreadAlarmExists;
  late List<dynamic> _postsInMyRegion = [];
  late List<dynamic> _allPosts = [];
  late List<dynamic> _filteredPost = [];
  final _orderFilterList = ["최신순", "첨삭순"];
  String _selectedOrderFilter = "최신순";
  String _selectedRegionFilter = "";
  final AdviceModel _adviceModel = AdviceModel();

  void _orderFilterHandler(String selectedOrderFilter) {
    setState(() {
      _selectedOrderFilter = selectedOrderFilter;
    });
  }

  void _regionFilterHandler(String selectedRegionFilter) {
    setState(() {
      _selectedRegionFilter = selectedRegionFilter;
    });
  }

  void _applyFilters(String selectedRegionFilter, String selectedOrderFilter) {
    List<Map<String, dynamic>> filteredPosts = [..._allPosts];

    if (selectedRegionFilter != "전지역") {
      filteredPosts = filteredPosts
          .where((post) =>
              post["selectedRegionsList"].contains(selectedRegionFilter))
          .toList();
    }

    if (selectedOrderFilter == "최신순") {
      filteredPosts.sort((a, b) =>
          b["createdAt"].compareTo(a["createdAt"])); // Most recent first
    } else if (selectedOrderFilter == "첨삭순") {
      filteredPosts.sort(
          (a, b) => b["adviceCount"].compareTo(a["adviceCount"])); // 첨삭 많은순
    }

    setState(() {
      _filteredPost = filteredPosts;
    });
  }

  // 유저의 현지인 인증이 유효한지 검사
  Future<Map<String, dynamic>> checkUserLocalAreaAuthIsValid() async {
    try {
      Map<String, dynamic> isValidAndLocalArea =
          await _adviceModel.checkUserLocalAreaAuthIsValid(context);
      print(isValidAndLocalArea);
      return isValidAndLocalArea;
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!현지인 인증 유효성 검증중  에러 발생 : $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('현지인 인증 유효성 검증중 오류가 발생했습니다. 다시 시도해주세요.')));
      return {"isValid": false, "localArea": null};
    }
  }

  // posts 가져오기
  Future<void> _loadPostData(String localArea) async {
    try {
      Map<String, dynamic> result =
          await _adviceModel.getPostsData(context, localArea);
      print(result);
      print(result['postsInMyRegion']);
      print(result['postsInMyRegion'].runtimeType);
      print(result['unreadAlarmExists']);
      setState(() {
        _postsInMyRegion = result['postsInMyRegion'];
        _allPosts = result['allPosts'];
        _filteredPost = _allPosts;
        _unreadAlarmExists = result['unreadAlarmExists'];
        _isLoading = false;
      });
      print(result);
    } catch (e) {
      LoadingOverlay.hide();
      print("!!!!!!!!!!!!!!!!!!포스트 데이터 로드 중 에러 발생 : $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    LoadingOverlay.show(context);
    // 유저의 현지인 인증이 유효한지 검사
    Map<String, dynamic> isValidAndLocalArea =
        await checkUserLocalAreaAuthIsValid();
    // 유효성 여부 통과 확인
    if (!isValidAndLocalArea['isValid']) {
      LoadingOverlay.hide();
      setState(() {
        _isLoading = true;
      });
      // showDialog
      // Navigate.push to local_area_auth screen
      CustomDialog.showOneButtonDialog(
        context,
        "현지인 인증이 만료 되었습니다. 현지인 인증이 유효한 유저만 여행 첨삭소 이용이 가능합니다.",
        "확인",
        () => navigateToLocalAreaAuthScreen(),
        barrierColor: Colors.black.withOpacity(0.8),
      );
    } else {
      setState(() {
        _localArea = isValidAndLocalArea['localArea'];
        _selectedOrderFilter = _orderFilterList[0];
        _selectedRegionFilter = "전지역";
      });
      // post 가져오기
      await _loadPostData(isValidAndLocalArea['localArea']);
    }
  }

  Future<void> navigateToLocalAreaAuthScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocalAreaAuthScreen()),
    );
    // 기다리다가 돌아오면 트리거
    if (result == true) {
      _reloadPageData();
    }
  }

  // 유저가 3개 이상의 장소가 등록된 여행 일정이 있는지 체크 후
  // dialog 를 보여주던지 bottom sheet 로 여행을 뿌려주던지
  // 성능을 위해서 한번에 다 가져온다
  Future<void> _checkIfUserHasTrips() async {
    try {
      List<dynamic> userTripData =
          await _adviceModel.checkIfUserHasTrips(context);
      print(userTripData);
      if (userTripData.isEmpty) {
        showDialog(
            context: context,
            builder: (context) {
              return ShortageDialog();
            });
      } else {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return PostBottomSheet(trips: userTripData);
            });
      }
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!글쓰기 검증중 에러 발생 : $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('글쓰기 검증중 오류가 발생했습니다. 다시 시도해주세요.')));
    }
  }

  Future<void> _navigateToAlarmPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlarmScreen()),
    );

    if (result == true) {
      _reloadPageData();
    }
  }

  Future<void> _navigateToPostViewPage(int postId) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostViewScreen(postId: postId)));

    if (result == true) {
      _reloadPageData();
    }
  }

  void _reloadPageData() async {
    setState(() {
      _isLoading = true; // Indicate loading while fetching data
    });
    await _loadData(); // Fetch the data
    setState(() {
      _isLoading = false; // Stop loading after data is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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
          title: Text(_localArea,
              style: Theme.of(context).textTheme.headlineLarge),
          actions: [
            IconButton(
                onPressed: _navigateToAlarmPage,
                splashRadius: 24,
                splashColor: Color.fromARGB(70, 43, 192, 228),
                highlightColor: Color.fromARGB(50, 43, 192, 228),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_outlined),
                    // 새로운 알림 여부
                    if (_unreadAlarmExists)
                      Positioned(
                        right: -1,
                        top: 1,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ),
                      )
                  ],
                )),
          ],
        ),
        body: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Recommendations(
                postsInMyRegion: _postsInMyRegion, localArea: _localArea),
            SizedBox(
              height: 16,
            ),
            PostFilter(
              orderFilterList: _orderFilterList,
              orderFilterHandler: _orderFilterHandler,
              selectedOrderFilter: _selectedOrderFilter,
              selectedRegionFilter: _selectedRegionFilter,
              regionFilterHandler: _regionFilterHandler,
              applyFilters: _applyFilters,
            ),
            SizedBox(
              height: 16,
            ),
            PostList(
                filteredPost: _filteredPost,
                navigateToPostViewPage: _navigateToPostViewPage)
          ]),
        ),
        floatingActionButton: Container(
            width: 65,
            height: 60,
            child: FloatingActionButton(
              onPressed: () {
                _checkIfUserHasTrips();
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text(
                      "글쓰기",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.white),
                    )
                  ]),
            )));
  }
}
