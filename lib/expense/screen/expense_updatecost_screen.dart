import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/expense/model/expense_model.dart';

class ExpenseUpdateCostScreen extends StatefulWidget {
  final int expenseId;
  final int tripId;
  final String selectedDate; // ExpenseScreen에서 전달된 날짜
  final List<String> availableDates;
  final Map<String, dynamic> groupedExpenses;

  const ExpenseUpdateCostScreen({
    super.key,
    required this.expenseId,
    required this.tripId,
    required this.selectedDate,
    required this.availableDates,
    required this.groupedExpenses,
  });

  @override
  State<ExpenseUpdateCostScreen> createState() => _ExpenseUpdateCostScreen();
}

class _ExpenseUpdateCostScreen extends State<ExpenseUpdateCostScreen> {
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
  // 날짜 옵션

  List<Map<String, dynamic>> _participants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _fetchExpenseDetails();
    if (widget.selectedDate == 'preparation') {
      _selectedDate = '여행 준비';
    } else if (widget.groupedExpenses.containsKey(widget.selectedDate)) {
      final dateDetail = widget.groupedExpenses[widget.selectedDate]?['date'] ?? '';
      _selectedDate = '${widget.selectedDate} $dateDetail';
    } else {
      _selectedDate = widget.selectedDate; // fallback: 원래 값 사용
    }

  }

  Future<void> _fetchParticipants() async {
    try {
      final users = await ExpenseModel().getUsersByTripId(widget.tripId, context);
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
    if (_selectedDate == 'preparation') {
      return '여행 준비';
    }
    final dateDetail = widget.groupedExpenses[_selectedDate]?['date'] ?? '';
    return '$_selectedDate $dateDetail';
  }

  Future<void> _fetchExpenseDetails() async {
    try {
      final expenseData = await ExpenseModel().getExpenseById(widget.expenseId, context);
      setState(() {
        _descriptionController.text = expenseData['description'] ?? '';
        _amountController.text = expenseData['amount'].toString();
        _selectedPaymentMethod = expenseData['paymentMethod'] ?? '현금';
        _selectedCategory = expenseData['category'] ?? '숙소';
        _selectedDate = expenseData['date'] ?? '날짜 선택';

        _participants = List<Map<String, dynamic>>.from(expenseData['participants'].map((user) => {
          'id': user['id'],
          'nickname': user['nickname'],
          'isChecked': user['isChecked'] ?? false,
          'isPaid': user['isPaid'] ?? false,
        }));
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching expense details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  /// 날짜 선택 BottomSheet
  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('날짜 선택', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...widget.availableDates.map((date) {
                final formattedDate = date == "preparation"
                    ? '여행 준비'
                    : '$date ${widget.groupedExpenses[date]?['date'] ?? ''}';

                return ListTile(
                  title: Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedDate == date ? pointBlueColor : blackColor,
                    ),
                  ),
                  trailing: _selectedDate == date
                      ? const Icon(Icons.check, color: pointBlueColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDate = date; // 선택된 날짜로 업데이트
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
                  title: Text(method),
                  trailing: _selectedPaymentMethod == method
                      ? const Icon(Icons.check, color: Colors.blue)
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

  void _updateExpense() async {
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

    // userId를 Integer로 변환
    final expenseData = {
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
      final expenseModel = ExpenseModel();
      await expenseModel.updateExpense(widget.expenseId, expenseData, context);
      print('Expense updated successfully');
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText : '금액 입력',
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 사용자 ID 표시
                    Expanded(
                      child: Text(
                        user['nickname'], // userId를 UI에 표시
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    // 결제 체크박스
                    Column(
                      children: [
                        const Text('결제'),
                        Checkbox(
                          value: user['isPaid'] ?? false,
                          onChanged: (value) {
                            setState(() {
                              user['isPaid'] = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    // 함께 체크박스
                    Column(
                      children: [
                        const Text('함께'),
                        Checkbox(
                          value: user['isChecked'] ?? false,
                          onChanged: (value) {
                            setState(() {
                              user['isChecked'] = value!;
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateExpense,
                child: const Text('완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

