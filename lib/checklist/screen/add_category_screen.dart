
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/checklist/model/checklist_model.dart';

class AddCategoryScreen extends StatefulWidget {

  @override
  State<AddCategoryScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddCategoryScreen> {
  final ChecklistModel _checklistModel = ChecklistModel();
  final TextEditingController _controller = TextEditingController();

  void _addCategory() async {
    final categoryName = _controller.text.trim();

    if (categoryName.isEmpty) {
      return;
    }

    try {
      final response = await _checklistModel.addCategory({'name': categoryName}, context);
      if (response == "카테고리가 추가되었습니다.") {
        Navigator.pop(context, true);
      } else {
        print('카테고리 추가 실패');
      }
    }catch(e) {
      print('카테고리 추가 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카테고리 추가')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: '카테고리 이름'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCategory,
              child: Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}
