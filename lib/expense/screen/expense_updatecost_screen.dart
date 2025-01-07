import 'package:flutter/material.dart';
import 'package:flutter_locatrip/expense/model/expense_model.dart';

class ExpenseUpdateCostScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseUpdateCostScreen({super.key, required this.expenseId});

  @override
  _ExpenseUpdateCostScreenState createState() =>
      _ExpenseUpdateCostScreenState();
}

class _ExpenseUpdateCostScreenState extends State<ExpenseUpdateCostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  List<Map<String, dynamic>> _paidByUsers = [];
  List<Map<String, dynamic>> _participants = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenseDetails();
  }

  Future<void> _fetchExpenseDetails() async {
    try {
      final expenseData = await ExpenseModel().getExpenseById(widget.expenseId);
      setState(() {
        _descriptionController.text = expenseData['description'];
        _amountController.text = expenseData['amount'].toString();
        _paymentMethodController.text = expenseData['paymentMethod'];
        _paidByUsers = List<Map<String, dynamic>>.from(expenseData['paidByUsers']);
        _participants = List<Map<String, dynamic>>.from(expenseData['participants']);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching expense details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateExpense() async {
    try {
      await ExpenseModel().updateExpense(
        widget.expenseId,
        {
          'description': _descriptionController.text,
          'amount': double.parse(_amountController.text),
          'paymentMethod': _paymentMethodController.text,
          'paidByUsers': _paidByUsers,
          'participants': _participants,
        },
      );
      Navigator.pop(context, true); // 수정 완료 후 이전 화면으로 돌아감
    } catch (e) {
      print('Error updating expense: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('비용 수정')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '설명'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: '금액'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _paymentMethodController,
              decoration: InputDecoration(labelText: '결제 수단'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateExpense,
              child: Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
