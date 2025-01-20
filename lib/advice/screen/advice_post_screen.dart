import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/editors_list_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class AdvicePostScreen extends StatefulWidget {
  const AdvicePostScreen({Key? key}) : super(key: key);

  @override
  State<AdvicePostScreen> createState() => _AdvicePostScreenState();
}

class _AdvicePostScreenState extends State<AdvicePostScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isBottomSheetVisible = false;
  bool _isSelected = false;

  final List<Map<String, String>> adviceList = [
    {
      'author': '부산갈매기',
      'date': '2024-12-13',
      'content': '부산은 아름다운 항구 도시입니다...'
    },
    {'author': '서울나그네', 'date': '2024-12-14', 'content': '서울의 밤은 화려합니다...'},
    {'author': '광주빛고을', 'date': '2024-12-15', 'content': '광주는 문화의 중심지입니다...'},
    {'author': '경주빛고을', 'date': '2024-12-15', 'content': '경주는 문화의 중심지입니다...'},
    {'author': '서울고을', 'date': '2024-12-15', 'content': '서울는 문화의 중심지입니다...'},
    {'author': '동작구고을', 'date': '2024-12-15', 'content': '동작구는 문화의 중심지입니다...'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isBottom = _scrollController.position.pixels != 0;
        if (isBottom && !_isBottomSheetVisible) {
          setState(() {
            _isBottomSheetVisible = true;
          });
          _showBottomSheet();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildVerticalDashedLine() {
    return Container(
      width: 1.5, // 점선의 너비를 고정
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 점선 시작 위치 설정
        children: List.generate(
          5, // 점선 길이 설정
          (index) => index.isEven
              ? Container(height: 4, color: grayColor)
              : Container(height: 4, color: Colors.transparent), // 점선 간격
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '나를 위한 현지인의 첨삭이 마음에 들었다면 해당 글을 채택해 보시는 건 어떨까요? 🥰',
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 바텀시트 닫기
                  // 채택하기 기능 추가
                  _onSelect();
                },
                child: const Text('채택하기'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSelect() {
    setState(() {
      _isSelected = true; // 하이라이트 활성화
    });
  }

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
              // 이미 채택되었으면 아무것도 하지 않음
              if (!_isSelected) {
                _onSelect();
              }
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorsListScreen(),
                ),
              );*/
            },
            icon: Icon(
              Icons.recommend,
              color: _isSelected ? pointBlueColor : grayColor,
            ),
            label: Text(
              '채택하기',
              style: TextStyle(
                color: _isSelected ? pointBlueColor : grayColor,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
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

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                print(adviceList[index]);
                return _buildAdviceCard(adviceList[index + 1]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('2', '강남역', '관광명소 · 서울 강남구'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 2]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('3', '강남역', '관광명소 · 서울 강남구'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 3]);
              },
              childCount: 1,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSectionHeader('4', '강남역', '관광명소 · 서울 강남구'),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                height: 20,
                child: _buildVerticalDashedLine(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildAdviceCard(adviceList[index + 4]);
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
            color: grayColor.withOpacity(0.3),
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
              color: grayColor,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.3),
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
                color: grayColor,
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
                        color: grayColor,
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.2),
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
            backgroundColor: pointBlueColor,
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
                  color: grayColor,
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: grayColor.withOpacity(0.2),
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
                color: grayColor,
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
                        color: grayColor,
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
