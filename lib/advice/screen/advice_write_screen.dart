import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/mypage/widget/custom_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/advice_model.dart';

class AdviceWriteScreen extends StatefulWidget {
  final int postId;
  final int tripDayLocationId;
  final String locationName;

  const AdviceWriteScreen(
      {super.key,
      required this.postId,
      required this.tripDayLocationId,
      required this.locationName});

  @override
  State<AdviceWriteScreen> createState() => _AdviceWriteScreenState();
}

class _AdviceWriteScreenState extends State<AdviceWriteScreen> {
  late int _postId;
  late int _tripDayLocationId;
  late String _locationName;
  TextEditingController _contentsController = TextEditingController();
  final AdviceModel _adviceModel = AdviceModel();

  Future<void> _insertAdviceAndUserAlarm(
      int postId, int tripDayLocationId) async {
    if (_contentsController.text.isNotEmpty) {
      try {
        final FlutterSecureStorage storage = FlutterSecureStorage();
        final dynamic stringId = await storage.read(key: 'userId');
        final int userId = int.tryParse(stringId) ?? 0;
        final adviceNum = tripDayLocationId == 0 ? 1 : 2; //1는 전체, 2는 장소
        Map<String, Object> adviceData = {
          "postId": postId,
          "adviceNum": adviceNum,
          "userId": userId,
          "contents": _contentsController.text,
          "locationId": tripDayLocationId
        };
        final Map<String, dynamic> insertedAdvice =
            await _adviceModel.insertAdvice(context, adviceData);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("첨삭 등록")));

        Map<String, Object> userAlarmData = {
          "alarmNum": 1,
          "userId": userId,
          "local_advice_id": insertedAdvice['id']
        };

        final result =
            await _adviceModel.insertUserAlarm(context, userAlarmData);
        print(insertedAdvice);
        print(result);
        Navigator.pop(context);
      } catch (e) {
        print('포스트를 저장하는 중 에러가 발생했습니다 : $e');
      }
    } else {
      CustomDialog.showOneButtonDialog(
          context, "내용이 있어야 첨삭 등록이 가능합니다.", "확인", () => Navigator.pop(context));
    }
  }

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
    _tripDayLocationId = widget.tripDayLocationId;
    _locationName = widget.locationName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close_outlined)),
          // tripDayLocationId로 해당 항목의 Location name
          title: Text(_tripDayLocationId == 0 ? "전체 첨삭" : _locationName),

          actions: [
            TextButton(
                // 등록하는 함수
                onPressed: () {
                  _insertAdviceAndUserAlarm(_postId, _tripDayLocationId);
                },
                child: Text("등록",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: pointBlueColor)))
          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: TextField(
              controller: _contentsController,
              maxLines: null,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    200), // Limit to 200 characters
              ],
              decoration: InputDecoration(
                hintText: "이 장소일정에 대해 첨삭해주세요",
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: grayColor,
                    ),
                contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                border: InputBorder.none,
              ),
            ),
          ),
        ));
  }
}
