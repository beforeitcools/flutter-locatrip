import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/expense/model/expense_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExpenseExtracostScreen extends StatefulWidget {
  final int tripId;
  final String selectedDate; // ExpenseScreen에서 전달된 날짜
  final List<String> availableDates;
  final Map<String, dynamic> groupedExpenses;

  const ExpenseExtracostScreen({
    super.key,
    required this.tripId,
    required this.selectedDate,
    required this.availableDates,
    required this.groupedExpenses,
  });

  @override
  State<ExpenseExtracostScreen> createState() => _ExpenseExtracostScreenState();
  }

class _ExpenseExtracostScreenState extends State<ExpenseExtracostScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedPaymentMethod = '현금'; // 초기 결제 수단
  String _selectedCategory = '숙소'; // 초기 카테고리
  late String _selectedDate; // 선택된 날짜

  final List<String> _paymentMethods = ['현금', '카드']; // 결제 수단 목록
  final List<Map<String, dynamic>> _categories = [
    {'label': '숙소', 'icon': Icons.night_shelter},
    {'label': '식비', 'icon': Icons.restaurant},
    {'label': '교통', 'icon': Icons.directions_car},
    {'label': '관광', 'icon': Icons.confirmation_number},
    {'label': '쇼핑', 'icon': Icons.shopping_bag},
    {'label': '기타', 'icon': Icons.sms},
  ];

  final ExpenseModel expenseModel = ExpenseModel();

  List<Map<String, dynamic>> _participants = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late int currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _getCurrentUserId();

    if (widget.selectedDate == '여행 준비') {
      _selectedDate = '여행 준비';
    } else {
      _selectedDate = widget.selectedDate; // fallback: 원래 값 사용
    }
  }

  Future<void> _getCurrentUserId() async {
    final stringId = await _storage.read(key: 'userId');
    setState(() {
      currentUserId = int.tryParse(stringId ?? '') ?? 0;
    });
  }

  Future<void> _fetchParticipants() async {
    try {
      final users = await expenseModel.getUsersByTripId(widget.tripId, context);
      setState(() {
        _participants = users.map((user) {
          return {
            'id': user['id'],
            'nickname': user['nickname'],
            'isChecked': false,
            'isPaid': false,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching participants: $e');
    }
  }

  String get formattedDate {
    if (_selectedDate == '여행 준비' || _selectedDate == 'preparation') {
      return '여행 준비';
    }
    final dateDetail = widget.groupedExpenses[_selectedDate]?['date'];
    if (dateDetail != null && dateDetail.isNotEmpty) {
      return dateDetail;
    }
    else {
      return _selectedDate;
    }
  }

  /// 날짜 선택 BottomSheet
  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 화면 크기에 유연하게 반응하도록 설정
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4, // 바텀 시트 높이 고정
            ),
            child: Column(
              children: [
                // 제목
                const ListTile(
                  title: Text(
                    '날짜선택',
                    style: TextStyle(color: grayColor, fontSize: 15),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.groupedExpenses.length,
                    itemBuilder: (context, index) {
                      // 날짜별 항목
                      final dayEntry = widget.groupedExpenses.entries.elementAt(index);
                      final day = dayEntry.key;
                      final date = dayEntry.value['date'];

                      final formattedDate = day == "preparation"
                          ? '여행 준비'
                          : '$date';

                      return ListTile(
                        title: Text(
                          formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedDate == day
                                ? pointBlueColor
                                : blackColor,
                          ),
                        ),
                        trailing: _selectedDate == day
                            ? const Icon(Icons.check, color: pointBlueColor)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedDate = day;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 결제 수단 선택 BottomSheet
  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('결제 수단 선택', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ..._paymentMethods.map((method) {
                return ListTile(
                  title: Text(method,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedPaymentMethod == method ? pointBlueColor : blackColor,
                    ),
                  ),
                  trailing: _selectedPaymentMethod == method
                      ? const Icon(Icons.check, color: pointBlueColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = method; // 선택된 결제 수단 업데이트
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }


  void _saveExpense() async {
    DateTime? parsedDate;

    try {
      if (widget.selectedDate == '여행 준비') {
        parsedDate = null;
      } else {
        final RegExp datePattern = RegExp(r'(\d{2}\.\d{2})');
        final match = datePattern.firstMatch(widget.selectedDate);

        if (match != null) {
          final String datePart = match.group(1)!;
          final DateTime now = DateTime.now();
          parsedDate = DateTime.parse("${now.year}-$datePart".replaceAll('.', '-'));
        } else {
          throw FormatException('Invalid date format');
        }
      }
    } catch (e) {
      print('Error parsing date: $e');
      parsedDate = null;
    }

    final String? formattedDate = parsedDate != null
        ? "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}"
        : null;

    final expenseData = {
      'tripId': widget.tripId,
      'date': formattedDate,
      'category': _selectedCategory,
      'description': _descriptionController.text,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'paymentMethod': _selectedPaymentMethod,
      'paidByUsers': _participants
          .where((user) => user['isPaid'] == true)
          .map((user) => {
        'userId': int.tryParse(user['id'].toString()) ?? 0, // Integer로 변환
        'amount': (double.tryParse(_amountController.text) ?? 0.0) /
            _participants.length,
      })
          .toList(),
      'participants': _participants
          .where((user) => user['isChecked'] == true)
          .map((user) => {
        'userId': int.tryParse(user['id'].toString()) ?? 0, // Integer로 변환
        'amount': (double.tryParse(_amountController.text) ?? 0.0) /
            _participants.length,
      })
          .toList(),
    };
    try {
      await expenseModel.createExpense(expenseData, context);
      print('Expense saved successfully');
      Navigator.pop(context, true); // 이전 화면으로 돌아가기
    } catch (e) {
      print('Error saving expense: $e');
    }

    print('Expense data sent: $expenseData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),  // X 아이콘
          onPressed: () {
            Navigator.pop(context); // X 아이콘을 눌렀을 때 이전 화면으로 돌아갑니다.
          },
        ),
        title: const Text('비용 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 금액 입력
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,  // 배경 색상 채우기
                fillColor: lightGrayColor,  // 배경 색상 (흰색)
                hintText: '금액 입력',  // 힌트 텍스트
                hintStyle: TextStyle(
                  color: grayColor, // 힌트 텍스트 색상
                  fontSize: 25,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 60, horizontal: 16),  // 안쪽 여백 조정
                border: OutlineInputBorder(// 둥근 모서리
                  borderSide: BorderSide(
                    color: lightGrayColor,  // 연한 회색 테두리
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: lightGrayColor,  // 기본 테두리 색상
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: lightGrayColor,  // 포커스된 상태에서 테두리 색상
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 날짜 & 결제 수단
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showDatePicker,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '날짜 선택',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formattedDate),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _showPaymentPicker,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '결제 수단',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedPaymentMethod),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              '내용',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // 내용 입력 필드
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: '내용을 입력해주세요.',
                hintStyle: TextStyle(
                  color: grayColor, // 힌트 텍스트 색상
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            const Text(
              '카테고리',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 아이콘을 Wrap 레이아웃으로 정렬
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 130.0, // 가로 간격
              runSpacing: 12.0, // 세로 간격
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['label'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['label'];
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Icon(
                              category['icon'],
                              color: isSelected ? pointBlueColor : grayColor,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? pointBlueColor : grayColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 35),

            // 함께한 사람 섹션 (결제 및 함께 체크 가능)
            const Text(
              '함께한 사람',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            Column(
              children: _participants.map((user) {

                bool isCurrentUser = user['id'] == currentUserId;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 사용자 ID 표시
                    Expanded(
                      child: Row(
                        children:[
                          user['profile_pic'] != null && user['profile_pic'].isNotEmpty
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(user['profile_pic']),  // 프로필 이미지
                            radius: 20,  // 아이콘 크기
                          )
                              : Icon(Icons.person, color: pointBlueColor),
                          Text(
                        user['nickname'] + (isCurrentUser ? '(나)' : ''), // userId를 UI에 표시
                        style: const TextStyle(fontSize: 14),
                      ),
                      ],
                    ),
                    ),
                    // 결제 체크박스
                    Column(
                      children: [
                        const Text('결제'),
                        IconButton(
                          icon: Icon(
                            user['isPaid'] ?? false ? Icons.check_circle : Icons.check_circle,
                            color: user['isPaid'] ?? false ? pointBlueColor : grayColor, // 체크 여부에 따른 색상
                          ),
                          onPressed: () {
                            setState(() {
                              user['isPaid'] = !(user['isPaid'] ?? false);
                            });
                          },
                        ),
                      ],
                    ),
                    // 함께 체크박스
                    Column(
                      children: [
                        const Text('함께'),
                        IconButton(
                          icon: Icon(
                            user['isChecked'] ?? false ? Icons.check_circle : Icons.check_circle,
                            color: user['isChecked'] ?? false ? pointBlueColor : grayColor,
                          ),
                          onPressed: () {
                            setState(() {
                              user['isChecked'] = !(user['isChecked'] ?? false);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 완료 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pointBlueColor, // 배경 색상
                  foregroundColor: Colors.white, // 텍스트 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게 처리
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10), // 버튼 높이 조정
                ),
                onPressed: _saveExpense,
                child: const Text(
                  '완료',
                  style: TextStyle(
                    fontSize: 16, // 글꼴 크기
                    fontWeight: FontWeight.bold, // 텍스트 굵기
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

