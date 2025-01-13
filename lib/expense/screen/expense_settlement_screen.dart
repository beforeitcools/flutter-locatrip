import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
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
        leading: IconButton(
          icon: Icon(Icons.close),  // X 아이콘
          onPressed: () {
            Navigator.pop(context); // X 아이콘을 눌렀을 때 이전 화면으로 돌아갑니다.
          },
        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: grayColor,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트 간의 공간을 균등하게 배치
                    children: [
                      Text(
                        '누가 누구에게',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '얼마를',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16), // 텍스트와 선 사이의 간격
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: grayColor,
                  ),
                  SizedBox(height: 16),
                ],
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
                        Text.rich(
                          TextSpan(
                          text: '${currencyFormat.format(((transaction['amount'] as double) / 10).round() * 10)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16,
                            color: pointBlueColor
                          ),
                          children: [
                            TextSpan(
                              text: '원',
                              style: TextStyle(
                                color: Colors.black,
                          ),
                ),
                ],
                        ),
                  )
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
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: grayColor,
                ),
                SizedBox(height: 16),
                Text(
                '개인별 지출금액',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
                SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: grayColor,
                ),
                SizedBox(height: 8),
              ],
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
                    leading: user['profile_pic'] != null && user['profile_pic'].isNotEmpty
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(user['profile_pic']),  // 프로필 이미지
                      radius: 20,  // 아이콘 크기
                    )
                        : Icon(Icons.person, color: pointBlueColor),
                    title: Text(
                      '${user['nickname']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currencyFormat.format(((user['spent'] as double) / 10 ).round() * 10)}원',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '결제: ${currencyFormat.format(user['paid'])}원',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey),
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
