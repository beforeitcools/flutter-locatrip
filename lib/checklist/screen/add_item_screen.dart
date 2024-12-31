
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/checklist/model/checklist_model.dart';

class AddItemScreen extends StatefulWidget {

  final int categoryId;

  AddItemScreen({required this.categoryId});

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
          {'name': itemName}
      );
      if (response == "항목이 추가되었습니다.") {
        await _checklistModel.getItemsByCategory(widget.categoryId);
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
                decoration: InputDecoration(labelText: '직접 입력'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addItem,
                child: Text('추가'),
              ),
            ],
          ),
      ),
    );
  }
}
