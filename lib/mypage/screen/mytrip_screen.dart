import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/category_tab_menu_widget.dart';
import 'package:flutter_locatrip/mypage/widget/mytrip_list_tile_widget.dart';

class MytripScreen extends StatefulWidget {
  const MytripScreen({super.key});

  @override
  State<MytripScreen> createState() => _MytripScreenState();
}

class _MytripScreenState extends State<MytripScreen> {
  final MypageModel _mypageModel = MypageModel();
  int _selectedIndex = 0; // 탭한 index(default: 0)
  late List<List<dynamic>> _myTrips = List.filled(2, []);
  List<String> _categories = ["다가오는 여행", "지난 여행"];
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

  Future<void> deleteTrip(int tripId) async {
    try {
      LoadingOverlay.show(context);
      String result = await _mypageModel.deleteTrip(context, tripId);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));

      setState(() {
        _myTrips[_selectedIndex]
            .removeWhere((trip) => trip['tripId'] == tripId);
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!트립 삭제중  에러 발생 : $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('트립 삭제 중 오류가 발생했습니다. 다시 시도해주세요.')));
    } finally {
      await _loadMyTripData();
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
                    child: MytripListTileWidget(
                      selectedIndex: _selectedIndex,
                      myTrips: _myTrips,
                      deleteTrip: deleteTrip,
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
