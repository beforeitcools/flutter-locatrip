import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final MypageModel _mypageModel = MypageModel();
  late List<dynamic> _alarmList;
  bool _isLoading = true;

  Future<void> _loadMyAlarmData() async {
    try {
      LoadingOverlay.show(context);
      List<dynamic> alarmData = await _mypageModel.getMyAlarmData(context);
      print("result: $alarmData");

      setState(() {
        _alarmList = alarmData;
        print("_alarmList: $_alarmList");
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!알림 중 에러 발생 : $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyAlarmData();
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
        title: Text("알림", style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
