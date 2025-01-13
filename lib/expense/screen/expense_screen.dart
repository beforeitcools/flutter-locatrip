import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/expense/model/expense_model.dart';
import 'package:flutter_locatrip/expense/screen/expense_extracost_screen.dart';
import 'package:flutter_locatrip/expense/screen/expense_settlement_screen.dart';
import 'package:flutter_locatrip/expense/screen/expense_updatecost_screen.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  final int tripId;

  const ExpenseScreen({super.key, required this.tripId});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseModel expenseModel = ExpenseModel();
  Map<String, dynamic> groupedExpenses = {};
  bool isLoading = true;
  bool isEditing = false;

  String selectedPeriod = '기간전체';

  String region = '지역을 불러오는 중...';

  final Map<String, IconData> categoryIcons = {
    '숙소': Icons.night_shelter,
    '식비': Icons.restaurant,
    '교통': Icons.directions_car,
    '관광': Icons.confirmation_number,
    '쇼핑': Icons.shopping_bag,
    '기타': Icons.sms,
  };

  final NumberFormat currencyFormat =
  NumberFormat('#,##0', 'ko_KR');

  @override
  void initState() {
    super.initState();
    loadExpensesGroupedByDays();
    loadRegion();
  }

  Future<void> loadExpensesGroupedByDays() async {
    try {
      final data = await expenseModel.getExpensesGroupedByDays(widget.tripId, context);
      setState(() {
        groupedExpenses = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadRegion() async {
    try {
      final regionData = await expenseModel.getRegionByTripId(widget.tripId, context);
      // regionData가 List<dynamic>일 때 첫 번째 요소를 가져옵니다.
      setState(() {
        region = regionData[0][0].toString();
      });
    } catch (e) {
      setState(() {
        region = '지역 정보 불러오기 실패';
      });
    }
    print(region);
  }

  void _navigateToSettlementScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseSettlementScreen(),
      ),
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('날짜선택', style: TextStyle(color: grayColor, fontSize: 15)),
              ),

              // '기간전체' 필터 옵션
              ListTile(
                title: Text(
                  '기간전체',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedPeriod == '기간전체' ? pointBlueColor : blackColor,
                  ),
                ),
                trailing: selectedPeriod == '기간전체'
                    ? const Icon(Icons.check, color: pointBlueColor)
                    : null,
                onTap: () {
                  setState(() {
                    selectedPeriod = '기간전체';
                  });
                  Navigator.pop(context);
                },
              ),

              // 날짜별 필터 옵션

              ...groupedExpenses.entries.map((entry) {
                final day = entry.key;
                final date = entry.value['date'];

                final formattedDate = day == "preparation"
                    ? '여행 준비'
                    : '$day ($date)';

                return ListTile(
                  title: Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedPeriod == day ? pointBlueColor : blackColor,
                    ),
                  ),
                  trailing: selectedPeriod == day
                      ? const Icon(Icons.check, color: pointBlueColor)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedPeriod = day;
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

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('순서 편집/삭제'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isEditing = true;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteExpense(int expenseId, String day) async {
    try {
      // UI에서 먼저 항목 제거
      setState(() {
        final dayExpenses = groupedExpenses[day]?['expenses'];
        if (dayExpenses != null) {
          dayExpenses.removeWhere((expense) => expense['id'] == expenseId);
          if (dayExpenses.isEmpty) {
            groupedExpenses.remove(day);
          }
        }
      });

      // 서버에 삭제 요청
      await expenseModel.deleteExpense(expenseId, context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비용이 성공적으로 삭제되었습니다.')),
      );
    } catch (e) {
      print('Error deleting expense: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
      // 오류 발생 시 UI 복구 (선택적)
      await loadExpensesGroupedByDays();
    }
  }

  void _navigateToUpdateExpense(int expenseId, String selectedDate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseUpdateCostScreen(
          expenseId: expenseId,
          tripId: widget.tripId,
          selectedDate: selectedDate,
          availableDates: groupedExpenses.keys.toList(),
          groupedExpenses: groupedExpenses,
        ),
      ),
    );

    if (result == true) {
      await loadExpensesGroupedByDays(); // 수정 후 목록 새로고침
      setState(() {});
    }
  }

  Future<void> _navigateToAddExpense(String selectedDate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseExtracostScreen(
          tripId: widget.tripId,
          selectedDate: selectedDate,
          availableDates: groupedExpenses.keys.toList(),
          groupedExpenses: groupedExpenses,
        ),
      ),
    );

    if (result == true) {
      // 비용이 추가되었으면 리스트 새로고침
      await loadExpensesGroupedByDays();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = selectedPeriod == '기간전체'
        ? groupedExpenses
        : {
      selectedPeriod: groupedExpenses[selectedPeriod],
    };

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "가계부",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                region == '지역을 불러오는 중...' ? '지역을 불러오는 중...' : '$region 여행',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: grayColor),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calculate),
              onPressed: _navigateToSettlementScreen,
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: _showEditOptions,
            ),
          ],
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: _showPeriodPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: grayColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedPeriod == 'preparation' ? '여행 준비' : '$selectedPeriod ${groupedExpenses[selectedPeriod]?['date'] ?? ''}',
                          style: const TextStyle(fontSize: 14, color: blackColor),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: grayColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: filteredExpenses.entries.map((entry) {
          final day = entry.key;
          final dayData = entry.value as Map<String, dynamic>;
          final date = dayData['date'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 제목
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  day == "preparation" ? '여행 준비' : '$day $date',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // 비용 목록 (ReorderableListView 사용)
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  // 드래그로 순서 변경
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = dayData['expenses'].removeAt(oldIndex);
                    dayData['expenses'].insert(newIndex, item);
                  });
                },
                children: [
                  ...(dayData['expenses'] as List).map((expense) {
                    final String category = expense['category'] ?? '기타';
                    final IconData icon = categoryIcons[category] ?? Icons.sms;

                    return ListTile(
                      key: ValueKey(expense['id']),
                      leading: isEditing
                          ? IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('삭제 확인'),
                                content: const Text('이 항목을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 다이얼로그 닫기
                                    },
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 다이얼로그 닫기
                                      _deleteExpense(expense['id'], day); // 삭제 처리
                                    },
                                    child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                          : Icon(icon, color: pointBlueColor),
                      title: Text(expense['description']),
                      trailing: isEditing
                          ? const Icon(Icons.drag_handle)
                          : Text('₩${currencyFormat.format(expense['amount'])}'),
                      onTap: () {
                        if (!isEditing) {
                          final formattedDay = day == "preparation" ? '여행 준비' : '$day $date';
                          _navigateToUpdateExpense(expense['id'], formattedDay);
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
              if (isEditing)
                Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: pointBlueColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: const Text('편집 완료')
                  ),
                ),
              // 비용 추가 버튼
              Padding(
                padding: const EdgeInsets.only(left: 15.0), // 왼쪽 여백을 제목의 첫 글자에 맞춰 설정
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blackColor,
                    side: const BorderSide(color: grayColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 160, vertical: 8),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    final formattedDay = day == "preparation" ? '여행 준비' : '$day $date';
                    _navigateToAddExpense(formattedDay);
                  },
                  child: const Text('비용 추가'),
                ),
              ),
            ],
          );
        }).toList(),
      )
    );
  }
}
