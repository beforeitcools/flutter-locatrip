import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';
import 'package:flutter_locatrip/mypage/widget/myposts_list_tile_widget.dart';

class MypostsScreen extends StatefulWidget {
  const MypostsScreen({super.key});

  @override
  State<MypostsScreen> createState() => _MypostsScreenState();
}

class _MypostsScreenState extends State<MypostsScreen> {
  final MypageModel _mypageModel = MypageModel();
  late List<dynamic> _myPosts = [];
  bool _isLoading = true;

  Future<void> _loadMypostData() async {
    try {
      LoadingOverlay.show(context);
      List<dynamic> result = await _mypageModel.getMypostData(context);
      print("result: $_myPosts");

      setState(() {
        _myPosts = result;
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!마이 트립 로드 중 에러 발생 : $e");
      setState(() {
        _myPosts = [];
      });
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMypostData();
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
        title: Text("내 포스트", style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: MypostsListTileWidget(
                      myPosts: _myPosts,
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
