import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/map/model/place.dart';
import 'package:flutter_locatrip/map/model/toggle_favorite.dart';
import 'package:flutter_locatrip/map/screen/location_detail_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/model/toggle_post_favorite.dart';
import 'package:flutter_locatrip/mypage/widget/category_tab_menu_widget.dart';
import 'package:flutter_locatrip/mypage/widget/myfavorites_list_tile_widget.dart';

class MyfavoritesScreen extends StatefulWidget {
  const MyfavoritesScreen({super.key});

  @override
  State<MyfavoritesScreen> createState() => _MyfavoritesScreenState();
}

class _MyfavoritesScreenState extends State<MyfavoritesScreen> {
  final MypageModel _mypageModel = MypageModel();
  int _selectedIndex = 0; // 탭한 index(default: 0)
  late List<List<dynamic>> _myFavorites = List.filled(2, []);
  List<String> _categories = ["장소", "게시글"];
  bool _isLoading = true;

  // like/unlike 토글과 location_detail_screen으로 보내기 위해서 필요한
  final ToggleFavorite _toggleFavorite = ToggleFavorite();
  final TogglePostFavorite _togglePostFavorite = TogglePostFavorite();

  void _categoryOnTabHandler(int categoryIndex) {
    setState(() {
      _selectedIndex = categoryIndex;
    });
  }

  Future<void> navigateToLocationDetailScreen(Place place) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LocationDetailScreen(
                place: place,
              )),
    );

    // 기다리다가 프로필 수정 후 돌아오면 트리거
    if (result == true) {
      _loadMyFavoriteData();
    }
  }

  // 내 여행 불러와서 다가오는 여행, 지난 여행 구분후 myTrips에 index 0,1로 추가
  Future<void> _loadMyFavoriteData() async {
    try {
      LoadingOverlay.show(context);
      Map<String, dynamic> result =
          await _mypageModel.getMyFavoriteData(context);
      print("result: $result");

      setState(() {
        _myFavorites[0] = result['locations'];
        _myFavorites[1] = result['posts'];
        print("myFavorites: $_myFavorites");
        print("myFavorites1: ${_myFavorites[0]}");
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!내저장 로드 중 에러 발생 : $e");
      setState(() {
        _myFavorites = [[], []];
      });
    } finally {
      LoadingOverlay.hide();
    }
  }

  // 장소 좋아요
  void _updateFavoriteStatus(
      bool isFavorite, Place place, int selectedIndex, int index) {
    setState(() {
      _myFavorites[selectedIndex][index]['isFavorite'] =
          !_myFavorites[selectedIndex][index]['isFavorite'];
    });
  }

  Future<void> toggleFavoriteStatus(
      Place place, bool isFavorite, int selectedIndex, int index) async {
    _toggleFavorite.toggleFavoriteStatus(place, isFavorite, context,
        () => _updateFavoriteStatus(isFavorite, place, selectedIndex, index));
  }

  // 게시글 좋아요
  void _updatePostFavoriteStatus(
      bool isFavorite, int selectedIndex, int index) {
    setState(() {
      _myFavorites[selectedIndex][index]['isFavorite'] =
          !_myFavorites[selectedIndex][index]['isFavorite'];
    });
  }

  Future<void> togglePostFavoriteStatus(
      bool isFavorite, int selectedIndex, int index, int postId) async {
    _togglePostFavorite.toggleFavoriteStatus(isFavorite, postId, context,
        () => _updatePostFavoriteStatus(isFavorite, selectedIndex, index));
  }

  @override
  void initState() {
    super.initState();
    _loadMyFavoriteData();
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
        title: Text("내 저장", style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Center(
        child: Column(
          children: [
            CategoryTabMenuWidget(
              categoryOnTabHandler: _categoryOnTabHandler,
              selectedIndex: _selectedIndex,
              categories: _categories,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: MyfavoritesListTileWidget(
                      selectedIndex: _selectedIndex,
                      myFavorites: _myFavorites,
                      updateFavoriteStatus: _updateFavoriteStatus,
                      toggleFavoriteStatus: toggleFavoriteStatus,
                      navigateToLocationDetailScreen:
                          navigateToLocationDetailScreen,
                      updatePostFavoriteStatus: _updatePostFavoriteStatus,
                      togglePostFavoriteStatus: togglePostFavoriteStatus,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
