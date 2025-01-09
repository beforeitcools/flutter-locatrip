import 'package:flutter/material.dart';

class AdviceViewScreen extends StatefulWidget {
  const AdviceViewScreen({Key? key}) : super(key: key);

  @override
  State<AdviceViewScreen> createState() => _AdviceViewScreenState();
}

class _AdviceViewScreenState extends State<AdviceViewScreen> {
  final List<Map<String, String>> adviceList = [
    {
      'author': '부산갈매기',
      'date': '2024-12-13',
      'content': '안녕하세요, 정재빈입니다. 부산은 제7영화제와...'
    },
    {
      'author': '부산나그네',
      'date': '2024-12-14',
      'content': '안녕하세요, 이정재입니다. 부산은 제7영화제와...'
    },
    {
      'author': '부산빛고을',
      'date': '2024-12-15',
      'content': '부산은 바다의 도시로 알려져 있습니다...'
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '첨삭보기',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(child: _buildAdviceList()),
        ],
      ),
    );
  }

  // 헤더 영역
  Widget _buildHeader() {
    return Stack(
      children: [
        // 점선 추가 (헤더 박스 중앙에서 시작)
        Positioned(
          left: 42, // 박스 중앙에 맞추기 위한 조정
          top: 50, // 중앙에서 시작
          bottom: -10, // 점선을 아래로 이어짐
          child: Container(
            width: 1,
            color: Colors.transparent,
            child: Column(
              children: List.generate(
                50,
                    (i) => i.isEven
                    ? Container(height: 4, color: Colors.grey.shade400)
                    : Container(height: 4, color: Colors.transparent),
              ),
            ),
          ),
        ),

        // 헤더 콘텐츠
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '강남역',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '관광명소 · 서울 강남구',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }


  // 게시글 리스트 영역
  Widget _buildAdviceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: adviceList.length,
      itemBuilder: (context, index) {
        final advice = adviceList[index];
        return _buildAdviceCard(
          author: advice['author']!,
          date: advice['date']!,
          content: advice['content']!,
        );
      },
    );
  }

  // 첨삭 카드 섹션
  Widget _buildAdviceCard({
    required String author,
    required String date,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    author,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showOptions(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // 더보기 메뉴
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('첨삭글보기'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
