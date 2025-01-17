import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/expense/model/expense_model.dart';
import 'package:flutter_locatrip/expense/screen/expense_extracost_screen.dart';
import 'package:flutter_locatrip/expense/screen/expense_settlement_screen.dart';
import 'package:flutter_locatrip/expense/screen/expense_updatecost_screen.dart';
import 'package:flutter_locatrip/map/model/app_overlay_controller.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  final int tripId;

  const ExpenseScreen({super.key, required this.tripId});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  int _selectedIndex = 0;
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
      final data = await expenseModel.getExpensesGroupedByDays(
          widget.tripId, context);
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

  List<String> getParticipantsNicknames(Map<String, dynamic> expense) {
    final participants = expense['participants'] ?? [];
    return participants.map<String>((user) => user['nickname'] as String)
        .toList();
  }

  String formatParticipantsNames(List<String> nicknames) {
    if (nicknames.isEmpty) return '결제자 정보 없음';
    if (nicknames.length == 1) return nicknames.first;
    if (nicknames.length == 2) return '${nicknames[0]}, ${nicknames[1]}';
    return '${nicknames[0]}, ${nicknames[1]} 외 ${nicknames.length - 2}명';
  }

  Future<void> loadRegion() async {
    try {
      final regionData = await expenseModel.getRegionByTripId(
          widget.tripId, context);

      setState(() {
        region = regionData[0][0].toString();
      });
    } catch (e) {
      setState(() {
        region = '지역 정보 불러오기 실패';
      });
    }
  }

  void _navigateToSettlementScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseSettlementScreen(tripId: widget.tripId),
      ),
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 화면 크기에 유연하게 반응하도록 설정
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery
                  .of(context)
                  .size
                  .height * 0.4, // 바텀 시트 높이 고정
            ),
            child: Column(
              children: [
                // 제목
                const ListTile(
                  title: Text(
                    '날짜선택',
                    style: TextStyle(
                        color: grayColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupedExpenses.length + 1, // '기간전체' + 날짜별 항목 수
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // '기간전체' 옵션
                        return ListTile(
                          title: Text(
                            '기간전체',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedPeriod == '기간전체'
                                  ? pointBlueColor
                                  : blackColor,
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
                        );
                      } else {
                        // 날짜별 항목
                        final dayEntry = groupedExpenses.entries.elementAt(
                            index - 1);
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
                              color: selectedPeriod == day
                                  ? pointBlueColor
                                  : blackColor,
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
                      }
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

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.15, // 높이를 약간 키워서 타이틀을 포함
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
                  // 타이틀 추가
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16), // 간격 추가
                    child: Text(
                      '설정',
                      style: TextStyle(
                        color: grayColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 순서 편집/삭제 ListTile
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
            ),
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
    final formattedDate = groupedExpenses[selectedDate]?['day'] ?? selectedDate;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExpenseUpdateCostScreen(
              expenseId: expenseId,
              tripId: widget.tripId,
              selectedDate: formattedDate,
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
    final formattedDate = groupedExpenses[selectedDate]?['day'] ?? selectedDate;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExpenseExtracostScreen(
              tripId: widget.tripId,
              selectedDate: formattedDate,
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
        preferredSize: const Size.fromHeight(130),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: grayColor,
                ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: _showPeriodPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: grayColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedPeriod == '기간전체'
                              ? '기간전체'
                              : selectedPeriod == 'preparation'
                              ? '여행 준비'
                              : '${groupedExpenses[selectedPeriod]?['date'] ??
                              selectedPeriod}',
                          style: const TextStyle(fontSize: 14,
                              color: blackColor),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: grayColor),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? isLoading
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
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  day == "preparation" ? '여행 준비' : '$date',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 비용 목록 (ReorderableListView 사용)
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = dayData['expenses'].removeAt(oldIndex);
                    dayData['expenses'].insert(newIndex, item);
                  });
                },
                children: List.generate(dayData['expenses'].length, (index) {
                  final expense = dayData['expenses'][index];
                  final String category = expense['category'] ?? '기타';
                  final IconData icon = categoryIcons[category] ?? Icons.sms;

                  return Column(
                    key: ValueKey(expense['id']),
                    children: [
                      ListTile(
                        leading: isEditing
                            ? IconButton(
                          icon: const Icon(
                              Icons.remove_circle, color: Colors.red),
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
                                        _deleteExpense(
                                            expense['id'], day); // 삭제 처리
                                      },
                                      child: const Text(
                                        '삭제',
                                        style: TextStyle(color: Colors.red),
                                      ),
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
                            ? ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.menu, color: grayColor),
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₩${currencyFormat.format(expense['amount'])}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatParticipantsNames(
                                  getParticipantsNicknames(expense)),
                              style:
                              const TextStyle(fontSize: 12, color: grayColor),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!isEditing) {
                            final formattedDay =
                            day == "preparation" ? '여행 준비' : '$date';
                            _navigateToUpdateExpense(
                                expense['id'], formattedDay);
                          }
                        },
                      ),
                      if (index < (dayData['expenses'] as List).length)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.2),
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: grayColor,
                                ),
                              ),
                              const SizedBox(width: 23),
                            ],
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),

              // 비용 추가 버튼
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blackColor,
                    side: const BorderSide(color: grayColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 160, vertical: 8),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    final formattedDay =
                    day == "preparation" ? '여행 준비' : '$date';
                    _navigateToAddExpense(formattedDay);
                  },
                  child: const Text('비용 추가'),
                ),
              ),
            ],
          );
        }).toList(),
      )
          : const SizedBox.shrink(),
      bottomNavigationBar: isEditing
          ? BottomAppBar(
        child: Container(
          height: 50,
          color: pointBlueColor,
          child: Center(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pointBlueColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    isEditing = false;
                  });
                },
                child: const Text(
                  '편집 완료',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}
