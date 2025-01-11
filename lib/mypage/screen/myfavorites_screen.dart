import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/category_tab_menu_widget.dart';

class MyfavoritesScreen extends StatefulWidget {
  const MyfavoritesScreen({super.key});

  @override
  State<MyfavoritesScreen> createState() => _MyfavoritesScreenState();
}

class _MyfavoritesScreenState extends State<MyfavoritesScreen> {
  final MypageModel _mypageModel = MypageModel();
  int _selectedIndex = 0; // 탭한 index(default: 0)
  late List<List<dynamic>> _myTrips = List.filled(2, []);
  List<String> _categories = ["장소", "게시글"];
  bool _isLoading = true;

  void _categoryOnTabHandler(int categoryIndex) {
    setState(() {
      _selectedIndex = categoryIndex;
    });
  }

  // 내 여행 불러와서 다가오는 여행, 지난 여행 구분후 myTrips에 index 0,1로 추가
  Future<void> _loadMyTripData() async {
    try {
      LoadingOverlay.show(context);
      Map<String, dynamic> result = await _mypageModel.getMyTripData(context);
      print("result: $result");
      print(result['futureTrips']);
      print(result['pastTrips']);
      setState(() {
        _myTrips[0] = result['futureTrips'];
        _myTrips[1] = result['pastTrips'];
        print("mytrips: $_myTrips");
        print("mytrips1: ${_myTrips[0]}");
        print("mytrips1: ${_myTrips[0]}[0]['title]");
        // print("mytrips2: ${_myTrips[0][title]}");
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!마이 트립 로드 중 에러 발생 : $e");
      setState(() {
        _myTrips = [[], []];
      });
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    // 백에서 불러오기
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
                      /*child: MytripListTileWidget(
                      selectedIndex: _selectedIndex,
                      myTrips: _myTrips,
                      deleteTrip: deleteTrip,
                    ),*/
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
