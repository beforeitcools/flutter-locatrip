import 'package:flutter/material.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '옵션을 선택하세요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('목적지 선택'),
            onTap: () {
              Navigator.pop(context); // BottomSheet 닫기
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('날짜 선택'),
            onTap: () {
              Navigator.pop(context); // BottomSheet 닫기
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('여행 동반자 선택'),
            onTap: () {
              Navigator.pop(context); // BottomSheet 닫기
            },
          ),
        ],
      ),
    );
  }
}
