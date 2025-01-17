
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/checklist/model/checklist_model.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class AddItemScreen extends StatefulWidget {

  final int categoryId;
  final int tripId;
  final int userId;

  AddItemScreen({
    required this.categoryId,
    required this.tripId,
    required this.userId,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final ChecklistModel _checklistModel = ChecklistModel();
  final TextEditingController _controller = TextEditingController();

  void _addItem() async {
    final itemName = _controller.text.trim();

    if (itemName.isEmpty) {
      return;
    }

    try {
      final response = await _checklistModel.addItemToCategory(widget.categoryId,
          {'name': itemName,
           'tripId' : widget.tripId,
           'userId' : widget.userId,
           'status' : 1,
          }, context
      );
      if (response == "항목이 추가되었습니다.") {
        await _checklistModel.getItemsByCategory(widget.categoryId, context);
        setState(() {
        });
        Navigator.pop(context, true);
      } else {
        print('아이템 추가 실패');
      }
    }catch(e) {
        print('아이템 추가 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('아이템 추가')),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: '아이템 이름'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addItem(),
                child: Text('추가',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pointBlueColor,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20), // Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
