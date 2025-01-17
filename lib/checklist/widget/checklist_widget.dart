import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChecklistWidget extends StatefulWidget {
  final Map<String, dynamic> category;
  final Function(int, bool) onItemChecked;
  final VoidCallback onItemAdd;
  final bool isEditing; // 편집 모드 여부
  final VoidCallback onDelete; // 삭제 버튼 클릭 시 호출되는 콜백
  final VoidCallback onDeleteItems;
  final Function(Map<String, dynamic>) onItemDelete;

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
  _ChecklistWidgetState createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  bool _isExpanded = false; // 항목 확장 여부

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카테고리 제목을 클릭하면 항목을 확장하거나 축소
        ListTile(
          title: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded; // 항목 확장/축소 상태 변경
              });
            },
            child: Row(
              children: [
                Text(
                  widget.category['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          trailing: widget.isEditing
              ? IconButton(
            icon: Icon(Icons.more_horiz, color: grayColor),
            onPressed: widget.onDelete,
          )
              : IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more, // 확장/축소 아이콘 변경
              color: grayColor,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded; // 항목 확장/축소 토글
              });
            },
          ),
        ),
        // 항목들이 확장된 상태에서만 보이도록 Column에 넣기
        if (_isExpanded)
          Column(
            children: [
              // 카테고리 내 아이템들
              ...List.generate(
                widget.category['items'].length,
                    (index) {
                  var item = widget.category['items'][index];
                  return ListTile(
                    leading: Checkbox(
                      value: item['isChecked'] ?? false,
                      shape: CircleBorder(),
                      activeColor: Colors.white,
                      checkColor: pointBlueColor,
                      onChanged: widget.isEditing
                          ? null
                          : (bool? value) {
                        widget.onItemChecked(index, value ?? false);
                        setState(() {
                          item['isChecked'] = value ?? false;
                        });
                        },
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: widget.isEditing ? grayColor : Colors.black,
                      ),
                    ),
                    trailing: widget.isEditing
                        ? IconButton(
                      icon: Icon(Icons.more_horiz, color: grayColor),
                      onPressed: () {
                        widget.onItemDelete(item);
                      },
                    )
                        : null,
                  );
                },
              ).toList(),

              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 28),
                leading: Icon(Icons.radio_button_unchecked,
                    color: widget.isEditing ? grayColor : pointBlueColor),
                title: Text(
                  '아이템 추가',
                  style: TextStyle(
                    color: widget.isEditing ? grayColor : Colors.black,
                  ),
                ),
                onTap: widget.isEditing ? null : widget.onItemAdd,
              ),
            ],
          ),
      ],
    );
  }
}
