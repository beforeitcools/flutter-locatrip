import 'package:flutter/material.dart';
import 'package:flutter_locatrip/checklist/screen/add_item_screen.dart';

import '../../common/widget/color.dart';

class ChecklistWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final Function(int, bool) onItemChecked;
  final VoidCallback onItemAdd;
  final bool isEditing; // 편집 모드 여부
  final VoidCallback onDelete; // 삭제 버튼 클릭 시 호출되는 콜백
  final VoidCallback onDeleteItems;
  final Function(int) onItemDelete;

  ChecklistWidget({
    required this.category,
    required this.onItemChecked,
    required this.onItemAdd,
    required this.isEditing,
    required this.onDelete,
    required this.onDeleteItems,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Text(
            category['name'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      trailing: isEditing
          ? IconButton(
              icon: Icon(Icons.more_horiz, color: grayColor),
              onPressed: onDelete,
            )
          : Icon(Icons.expand_more),
      children: [
        // 카테고리 내 아이템들
        ...List.generate(
          category['items'].length,
          (index) {
            var item = category['items'][index];
            return ListTile(
              leading: Checkbox(
                value: item['isChecked'] ?? false,
                shape: CircleBorder(),
                onChanged: isEditing
                    ? null
                    : (bool? value) {
                        onItemChecked(index, value ?? false);
                      },
              ),
              title: Text(
                item['name'],
                style: TextStyle(
                  color: isEditing ? grayColor : Colors.black,
                ),
              ),
              trailing: isEditing
                  ? IconButton(
                      icon: Icon(Icons.more_horiz, color: grayColor),
                      onPressed: () {
                        onItemDelete(item['id']);
                      },
                    )
                  : null,
            );
          },
        ).toList(),
        // 아이템 추가 버튼
        ListTile(
          leading: Icon(Icons.radio_button_unchecked,
              color: isEditing ? grayColor : pointBlueColor),
          title: Text(
            '아이템 추가',
            style: TextStyle(
              color: isEditing ? grayColor : Colors.black,
            ),
          ),
          onTap: isEditing ? null : onItemAdd,
        ),
      ],
    );
  }
}
