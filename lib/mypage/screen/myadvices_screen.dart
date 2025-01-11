import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/myadvices_list_tile_widget.dart';

class MyadvicesScreen extends StatefulWidget {
  const MyadvicesScreen({super.key});

  @override
  State<MyadvicesScreen> createState() => _MyadvicesScreenState();
}

class _MyadvicesScreenState extends State<MyadvicesScreen> {
  final MypageModel _mypageModel = MypageModel();
  late List<dynamic> _myAdvices = [];
  bool _isLoading = true;

  Future<void> _loadMyAdviceData() async {
    try {
      LoadingOverlay.show(context);
      List<dynamic> result = await _mypageModel.getMyAdviceData(context);
      print("result: $result");

      setState(() {
        _myAdvices = result;
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!마이 트립 로드 중 에러 발생 : $e");
      setState(() {
        _myAdvices = [];
      });
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyAdviceData();
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
        title: Text("내 첨삭", style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: MyadvicesListTileWidget(
                      myAdvices: _myAdvices,
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
