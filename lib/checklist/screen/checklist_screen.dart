import 'package:flutter/material.dart';
import 'package:flutter_locatrip/checklist/model/checklist_model.dart';
import 'package:flutter_locatrip/checklist/screen/add_category_screen.dart';
import 'package:flutter_locatrip/checklist/screen/add_item_screen.dart';
import 'package:flutter_locatrip/checklist/widget/checklist_widget.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChecklistScreen extends StatefulWidget {
  final int tripId;
  final int userId;

  const ChecklistScreen({
    super.key,
    required this.tripId,
    required this.userId,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final ChecklistModel _checklistModel = ChecklistModel();
  List<dynamic> _categories = [];
  List<int> _selectedItemIds = [];
  int _selectedIndex = 0;
  bool _isEditing = false;
  String region = '지역을 불러오는 중...';
  String tripDuration = '여행 기간을 불러오는 중...';

  late int tripId;
  late int userId;

  @override
  void initState() {
    super.initState();
    tripId = widget.tripId;
    userId = widget.userId;
    _loadCategories();
    _loadRegion();
    _loadTripDuration();
  }

  Future<void> _loadTripDuration() async {
    try{
      final duration = await _checklistModel.getTripDuration(tripId, context);
      setState(() {
        tripDuration = duration;
      });
    } catch (e) {
      setState(() {
        tripDuration = '여행 기간 불러오기 실패';
      });
      print('Error fetching trip duration: $e');
    }
  }

  Future<void> _loadRegion() async {
    try {
      // regionData가 List<List<dynamic>> 형태일 수 있기 때문에 첫 번째 리스트를 사용
      final regionData = await _checklistModel.getRegionByTripId(tripId, context);
      if (regionData.isNotEmpty && regionData[0].isNotEmpty) {
        setState(() {
          region = regionData[0][0].toString();  // regionData[0][0]이 지역명이라 가정
        });
      } else {
        setState(() {
          region = '지역 정보 불러오기 실패';
        });
      }
    } catch (e) {
      setState(() {
        region = '지역 정보 불러오기 실패';
      });
      print('Error fetching region: $e');
    }
  }

  void _loadCategories() async {
    try {

      await _checklistModel.addDefaultCategories(tripId, userId, context);

      var categories = await _checklistModel.getCategories(context);

      categories = categories.where((category) {
        if (category == null || category.isEmpty) return false; // null 또는 빈 객체는 제외
        final status = category['status'] ?? 0; // status가 null이면 기본값 0
        print("Category status: $status"); // 디버깅용 로그
        return status == 1; // status가 1인 카테고리만 포함
      }).toList();

      for (var category in categories) {
        var items = await _checklistModel.getItemsByCategory(category['id'], context);
        category['items'] = items;
      }
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print("카테고리 로드 중 오류 발생: $e");
    }
  }

  void _showDeleteConfirmation(int categoryId, String currentName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              ListTile(
                title: const Text('삭제하기'),
                onTap: () async {
                  try {
                    await _checklistModel.deleteCategory(categoryId, context);
                    Navigator.pop(context); // 하단 시트 닫기
                    _loadCategories(); // 카테고리 재로딩
                  } catch (e) {
                    print("삭제 실패: $e");
                  }
                },
              ),
              ListTile(
                title: const Text('이름 수정'),
                onTap: () {
                  Navigator.pop(context); // 하단 시트 닫기
                  _showEditCategoryDialog(categoryId, currentName); // 이름 수정 다이얼로그 호출
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showItemDeleteConfirmation(int itemId, String currentName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              ListTile(
                title: const Text('삭제하기'),
                onTap: () async {
                  try {
                    await _checklistModel.deleteItems([itemId], context);
                    Navigator.pop(context); // 하단 시트 닫기
                    _loadCategories(); // 카테고리 재로딩
                  } catch (e) {
                    print("삭제 실패: $e");
                  }
                },
              ),
              ListTile(
                title: const Text('이름 수정'),
                onTap: () {
                  Navigator.pop(context); // 하단 시트 닫기
                  _showEditItemDialog(itemId, currentName); // 이름 수정 다이얼로그 호출
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditItemDialog(int itemId, String currentName) {
    final TextEditingController _controller =
    TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "이름 수정",
            style: TextStyle(color: grayColor),
          ),
          content: TextField(
            controller: _controller,
            maxLength: 30,
            decoration: InputDecoration(
              hintText: "최대 30글자로 아이템 이름 입력",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text(
                "취소",
                style: TextStyle(color: pointBlueColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newName = _controller.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  try {
                    await _checklistModel.updateItem(itemId, newName, context);
                    _loadCategories(); // 카테고리 갱신
                    Navigator.pop(context); // 다이얼로그 닫기
                  } catch (e) {
                    print("카테고리 이름 수정 중 오류: $e");
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                "확인",
                style: TextStyle(color: pointBlueColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(int categoryId, String currentName) {
    final TextEditingController _controller =
    TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "이름 수정",
            style: TextStyle(color: grayColor),
          ),
          content: TextField(
            controller: _controller,
            maxLength: 30,
            decoration: InputDecoration(
              hintText: "최대 30글자로 카테고리 이름 입력",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text(
                  "취소",
                style: TextStyle(color: pointBlueColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newName = _controller.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  try {
                    await _checklistModel.updateCategory(categoryId, newName, context);
                    _loadCategories(); // 카테고리 갱신
                    Navigator.pop(context); // 다이얼로그 닫기
                  } catch (e) {
                    print("카테고리 이름 수정 중 오류: $e");
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                  "확인",
                style: TextStyle(color: pointBlueColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedItems() async {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제할 항목을 선택해주세요.')),
      );
      return;
    }

    try {
      await _checklistModel.deleteItems(_selectedItemIds, context);
      _selectedItemIds.clear();
      _loadCategories();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('선택된 항목이 삭제되었습니다.')),
      );
    } catch(e) {
     print("삭제 실패: $e");
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('항목 삭제 실패: $e')),
     );
    }
  }

  void _addCategory(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryScreen(
        tripId: tripId,
        userId: userId,
      )),
    );

    if (result != null && result) {
      _loadCategories();
    }
  }

  void _updateItemCheckedStatus(int itemId, bool isChecked) async {
    try {
      await _checklistModel.updateItemCheckedStatus(itemId, isChecked, context);
    } catch (e) {
      print("체크 상태 업데이트 중 오류 발생: $e");
    }
  }

  void _navigateToAddItemScreen(BuildContext context, int categoryId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(categoryId: categoryId, tripId: tripId, userId: userId),
      ),
    );

    if (result != null) {
      _loadCategories();
    }
  }

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "체크리스트", // 기본 타이틀
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              region == '지역을 불러오는 중...' ? '지역을 불러오는 중...' : '$region 여행', // 지역 표시
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: grayColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              '편집',
              style: TextStyle(color: pointBlueColor),
            ),
          ),
        ],
      ),
      body: _categories.isEmpty
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$tripDuration • $region 여행",
                  style: TextStyle(
                    fontSize: 14,
                    color: grayColor,
                  ),
                ),
                Text(
                  "여행 준비",
                  style: TextStyle(
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
                Text(
                  "체크리스트",
                  style: TextStyle(
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
          // 카테고리 추가 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => _addCategory(context),
                  child: Text(
                    '카테고리 추가',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pointBlueColor,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$tripDuration • $region 여행",
                  style: TextStyle(
                    fontSize: 14,
                    color: grayColor,
                  ),
                ),
                Text(
                  "여행 준비",
                  style: TextStyle(
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
                Text(
                  "체크리스트",
                  style: TextStyle(
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
          // 리스트뷰 섹션
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length, // 기존 카테고리 수
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ChecklistWidget(
                  category: category,
                  onItemChecked: (itemIndex, isChecked) {
                    int itemId = category['items'][itemIndex]['id'];
                    if (isChecked) {
                      _selectedItemIds.add(itemId);
                    } else {
                      _selectedItemIds.remove(itemId);
                    }
                    _updateItemCheckedStatus(itemId, isChecked);
                    setState(() {
                      category['items'][itemIndex]['isChecked'] = isChecked;
                    });
                  },
                  onItemAdd: () {
                    _navigateToAddItemScreen(context, category['id']);
                  },
                  isEditing: _isEditing,
                  onDelete: () {
                    _showDeleteConfirmation(category['id'], category['name']);
                  },
                  onDeleteItems: _deleteSelectedItems,
                  onItemDelete: (item) {
                    int itemId = item['id'];
                    String itemName = item['name'];
                    _showItemDeleteConfirmation(itemId, itemName);
                  },
                );
              },
            ),
          ),
          // 카테고리 추가 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => _addCategory(context),
                  child: Text(
                    '카테고리 추가',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pointBlueColor,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "홈"),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), label: "지도"),
          BottomNavigationBarItem(
              icon: Icon(Icons.recommend_outlined), label: "여행첨삭소"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sms_outlined), label: "채팅"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: "마이페이지"),
        ],
      ),
    );
  }
}
