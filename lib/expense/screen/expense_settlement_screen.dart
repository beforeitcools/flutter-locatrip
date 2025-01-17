import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // 천 단위 콤마 포맷을 위해 추가
import 'package:flutter_locatrip/expense/model/expense_model.dart';

class ExpenseSettlementScreen extends StatefulWidget {
  final int tripId;

  ExpenseSettlementScreen({
    required this.tripId
  });

  @override
  _ExpenseSettlementScreenState createState() =>
      _ExpenseSettlementScreenState();
  }

class _ExpenseSettlementScreenState extends State<ExpenseSettlementScreen> {
  final ExpenseModel expenseModel = ExpenseModel();
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> userExpenses = [];
  bool isLoading = true;
  String bodyTitle = "일정 날짜";
  String bodyTitle2 = "지역 여행";
  String region = '지역을 불러오는 중...';

  final NumberFormat currencyFormat =
  NumberFormat('#,##0', 'ko_KR'); // 천 단위 포맷

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late int currentUserId;

  @override
  void initState() {
    super.initState();
    fetchTripDetails(widget.tripId);
    fetchSettlementDetails();
    loadRegion();
    _getCurrentUserId();
  }

  Future<void> fetchTripDetails(int tripId) async {
    try {
      final tripDetails = await expenseModel.getTripDetails(tripId, context);
      final startDate = tripDetails['startDate'];
      final endDate = tripDetails['endDate'];
      final region = (tripDetails['region'] as List).join(', ');

      setState(() {
        bodyTitle = "$startDate - $endDate";
        bodyTitle2 = "$region 여행";
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching trip details: $e');
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
  }

  Future<void> _getCurrentUserId() async {
    final stringId = await _storage.read(key: 'userId');
    setState(() {
      currentUserId = int.tryParse(stringId ?? '') ?? 0;
      isLoading = false;
    });
  }

  Future<void> fetchSettlementDetails() async {
    try {
      final settlementData = await expenseModel.getTotalSettlement(context);
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
        title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "정산내역",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            region == '지역을 불러오는 중...' ? '지역을 불러오는 중...' : '$region 여행',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: grayColor),
          ),
        ],
      ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 본문 최상단에 제목 추가
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 16.0, 16.0, 16.0), // 왼쪽 여백 24.0 추가
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bodyTitle, // 일정 날짜
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    bodyTitle2, // 지역 여행
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    '정산내역입니다.', // 지역 여행
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                ],
              ),
            ),

            // 기존의 '누가 누구에게' 섹션
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    thickness: 0.8,
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
                    thickness: 0.8,
                    color: grayColor,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // 기존의 내용들 유지
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                bool isCurrentFromUser = transaction['fromUserId'] == currentUserId;
                bool isCurrentToUser = transaction['toUserId'] == currentUserId;

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
                      '${transaction['fromNickname'] + (isCurrentFromUser ? '(나)' : '')} → ${transaction['toNickname'] + (isCurrentToUser ? '(나)' : '')}',
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                    thickness: 0.8,
                    color: grayColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '개인별 지출금액',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 0.8,
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
                bool isCurrentUser = (user['userId']) == currentUserId;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: user['profile_pic'] != null && user['profile_pic'].isNotEmpty
                        ? CircleAvatar(
                      backgroundImage:
                      NetworkImage(user['profile_pic']), // 프로필 이미지
                      radius: 20, // 아이콘 크기
                    )
                        : Icon(Icons.person, color: pointBlueColor),
                    title: Text(
                      user['nickname'] + (isCurrentUser ? '(나)' : ''),
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currencyFormat.format(((user['spent'] as double) / 10).round() * 10)}원',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '결제: ${currencyFormat.format(user['paid'])}원',
                          style: TextStyle(
                              fontSize: 16, color: grayColor),
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
