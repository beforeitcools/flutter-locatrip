import 'package:flutter/material.dart';

class EditorsListScreen extends StatefulWidget {
  final int postId;
  const EditorsListScreen({super.key, required this.postId});

  @override
  State<EditorsListScreen> createState() => _EditorsListScreenState();
}

class _EditorsListScreenState extends State<EditorsListScreen> {
  late int _postId;
  final List<String> editors = [
    "롯데자이언츠우승",
    "롯데자이언츠우승",
    "롯데자이언츠우승",
    "롯데자이언츠우승",
    "롯데자이언츠우승",
  ];

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('첨삭자 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: editors.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
            ),
            title: Text(
              editors[index],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // 첨삭자 상세 페이지로 이동
              print('${editors[index]} tapped');
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/*class EditorsListScreen extends StatelessWidget {
  final int postId;

  final List<String> editors = [
    "롯데자이언츠우승",
    "롯데자이언츠우승",
    "롯데자이언츠우승",
    "롯데자이언츠우승",
    "롯데자이언츠우승",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('첨삭자 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: editors.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
            ),
            title: Text(
              editors[index],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // 첨삭자 상세 페이지로 이동
              print('${editors[index]} tapped');
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Colors.grey,
        ),
      ),
    );
  }
}*/
