import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class AdvicePostScreen extends StatefulWidget {
  const AdvicePostScreen({Key? key}) : super(key: key);

  @override
  State<AdvicePostScreen> createState() => _AdvicePostScreenState();
}

class _AdvicePostScreenState extends State<AdvicePostScreen> {
  final List<Map<String, String>> adviceList = [
    {
      'author': '부산갈매기',
      'date': '2024-12-13',
      'content': '부산은 아름다운 항구 도시입니다...'
    },
    {
      'author': '서울나그네',
      'date': '2024-12-14',
      'content': '서울의 밤은 화려합니다...'
    },
    {
      'author': '광주빛고을',
      'date': '2024-12-15',
      'content': '광주는 문화의 중심지입니다...'
    },
    {
      'author': '경주빛고을',
      'date': '2024-12-15',
      'content': '경주는 문화의 중심지입니다...'
    },
    {
      'author': '서울고을',
      'date': '2024-12-15',
      'content': '서울는 문화의 중심지입니다...'
    },
    {
      'author': '동작구고을',
      'date': '2024-12-15',
      'content': '동작구는 문화의 중심지입니다...'
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('첨삭글'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // 채택하기 기능 추가
            },
            icon: const Icon(Icons.recommend, color: pointBlueColor),
            label: const Text(
              '채택하기',
              style: TextStyle(color: pointBlueColor),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 지도 섹션
          SliverToBoxAdapter(
            child: _buildMapSection(),
          ),

          // 메인 글 (지도 바로 아래에 표시)
          SliverToBoxAdapter(
            child: _buildMainAdviceCard(adviceList[0]),
          ),

          // 나머지 글 섹션
          SliverToBoxAdapter(
            child: _buildSectionHeader('1', '강남역', '관광명소 · 서울 강남구'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    print(adviceList[index]);
                return _buildAdviceCard(adviceList[index+1]);
                },
              childCount: 1,
            ),
          ),


          SliverToBoxAdapter(
            child: _buildSectionHeader('2', '강남역', '관광명소 · 서울 강남구'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildAdviceCard(adviceList[index+2]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('3', '강남역', '관광명소 · 서울 강남구'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildAdviceCard(adviceList[index+3]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('4', '강남역', '관광명소 · 서울 강남구'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildAdviceCard(adviceList[index+4]);
              },
              childCount: 1,
            ),
          ),

        ],
      ),
    );
  }

  /// 지도 섹션
  Widget _buildMapSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          'https://via.placeholder.com/400x200',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Text(
                  '이미지를 불러올 수 없습니다.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainAdviceCard(Map<String, String> advice) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자, 날짜, 프로필 이미지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 아이콘
              const Icon(
                Icons.account_circle,
                size: 24,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),

              // 작성자와 날짜
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      advice['author'] ?? '작성자 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      advice['date'] ?? '날짜 없음',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice['content']!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String number, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 카드 섹션
  /// 게시글 카드 (작성자, 날짜, 프로필 이미지)
  Widget _buildAdviceCard(Map<String, String> advice) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // 작성자, 날짜, 프로필 이미지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 아이콘
              const Icon(
                Icons.account_circle,
                size: 24,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),

              // 작성자와 날짜
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      advice['author'] ?? '작성자 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      advice['date'] ?? '날짜 없음',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 게시글 내용
          Text(
            advice['content'] ?? '내용 없음',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }



}
