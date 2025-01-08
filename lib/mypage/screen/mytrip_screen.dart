import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/category_tab_menu_widget.dart';
import 'package:flutter_locatrip/mypage/widget/list_tile_widget.dart';

class MytripScreen extends StatefulWidget {
  const MytripScreen({super.key});

  @override
  State<MytripScreen> createState() => _MytripScreenState();
}

class _MytripScreenState extends State<MytripScreen> {
  final MypageModel _mypageModel = MypageModel();
  int _selectedIndex = 0; // 탭한 index(default: 0)
  late List<Map<String, dynamic>> _myTrips = List.filled(2, {});
  List<String> _categories = ["다가오는 여행", "지난 여행"];
  bool _isLoading = true;

  void _categoryOnTabHandler(int categoryIndex) {
    setState(() {
      _selectedIndex = categoryIndex;
    });
  }

  // 내 여행 불러와서 다가오는 여행, 지난 여행 구분후 myTrips에 index 0,1로 추가
  void _loadMyTripData() async {
    try {
      LoadingOverlay.show(context);
      Map<String, dynamic> result = await _mypageModel.getMyTripData(context);
      setState(() {
        _myTrips[0] = result['futureTrips'];
        _myTrips[1] = result['pastTrips'];
        print("result: $result");
        print("mytrips: $_myTrips");
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!로드 중 에러 발생 : $e");
      setState(() {
        _myTrips = [{}, {}];
      });
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyTripData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading screen while data is fetching
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("내 여행", style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 165,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Center(
                child: Column(
                  children: [
                    CategoryTabMenuWidget(
                      categoryOnTabHandler: _categoryOnTabHandler,
                      selectedIndex: _selectedIndex,
                      categories: _categories,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    ListTileWidget(
                      selectedIndex: _selectedIndex,
                      myTrips: _myTrips,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "현재 위치로 현지인 인증하기",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size(380, 60),
                          backgroundColor: pointBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
