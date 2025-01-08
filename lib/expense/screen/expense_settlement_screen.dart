import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 천 단위 콤마 포맷을 위해 추가
import 'package:flutter_locatrip/expense/model/expense_model.dart';

class ExpenseSettlementScreen extends StatefulWidget {
  @override
  _ExpenseSettlementScreenState createState() =>
      _ExpenseSettlementScreenState();
}

class _ExpenseSettlementScreenState extends State<ExpenseSettlementScreen> {
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> userExpenses = [];
  bool isLoading = true;

  final NumberFormat currencyFormat =
  NumberFormat('#,##0', 'ko_KR'); // 천 단위 포맷

  @override
  void initState() {
    super.initState();
    fetchSettlementDetails();
  }

  Future<void> fetchSettlementDetails() async {
    try {
      final settlementData = await ExpenseModel().getTotalSettlement(context);
      setState(() {
        transactions =
        List<Map<String, dynamic>>.from(settlementData['transactions']);
        userExpenses =
        List<Map<String, dynamic>>.from(settlementData['userExpenses']);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching settlement details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 정산 내역'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 누가 누구에게 섹션
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '누가 누구에게',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      '${index + 1}.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(
                      '${transaction['fromNickname']} → ${transaction['toNickname']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currencyFormat.format(transaction['amount'])}원',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '얼마를',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            // 개인별 지출 금액 섹션
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '개인별 지출금액',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: userExpenses.length,
              itemBuilder: (context, index) {
                final user = userExpenses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                    title: Text(
                      '${user['nickname']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currencyFormat.format(user['spent'])}원',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '결제: ${currencyFormat.format(user['paid'])}원',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
