import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

class ExpenseModel {
  final dio = Dio();
  final String baseUrl = '$backUrl/expenses';

  Future<void> createExpense(Map<String, dynamic> expenseData, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.post(
        '$baseUrl/insert',
        data: {
          "tripId": expenseData['tripId'],
          "date": expenseData['date'],
          "category": expenseData['category'],
          "description": expenseData['description'],
          "amount": expenseData['amount'],
          "paymentMethod": expenseData['paymentMethod'],
          "paidByUsers": expenseData['paidByUsers'].map((user) {
            return {
              "userId": user['userId'],
              "amount": user['amount'],
            };
          }).toList(),
          "participants": expenseData['participants'].map((user) {
            return {
              "userId": user['userId'],
              "amount": user['amount'],
            };
          }).toList(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response: ${response.data}');
      if (response.statusCode == 200) {
        print('Expense successfully added.');
      } else {
        throw Exception('Failed to add expense. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createExpense: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getExpenses(BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get(baseUrl);
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('비용 목록 불러오기 실패');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getExpensesGroupedByDays(int tripId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get('$baseUrl/grouped-by-days/$tripId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('기간별 비용 조회 실패');
      }
    } catch(e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getExpenseById(int expenseId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get('$baseUrl/$expenseId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch expense details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching expense details: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> updateExpense(int expenseId, Map<String, dynamic> expenseData, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      print('Updating expense data: $expenseData');
      final response = await dio.put(
        '$baseUrl/$expenseId',
        data: {
          "date": expenseData['date'],
          "category": expenseData['category'],
          "description": expenseData['description'],
          "amount": expenseData['amount'],
          "paymentMethod": expenseData['paymentMethod'],
          "paidByUsers": expenseData['paidByUsers'].map((user) {
            return {
              "userId": user['userId'],
              "amount": user['amount'],
            };
          }).toList(),
          "participants": expenseData['participants'].map((user) {
            return {
              "userId": user['userId'],
              "amount": user['amount'],
            };
          }).toList(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Expense successfully updated.');
      } else {
        throw Exception('Failed to update expense. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating expense: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getTotalSettlement(BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get('$baseUrl/settlement/total');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('정산 내역 불러오기 실패');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteExpense(int expenseId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.delete('$baseUrl/${expenseId}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Expense successfully deleted');
      } else {
        throw Exception('Failed to delete expense. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating expense: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByTripId(int tripId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get('$baseUrl/trip/$tripId/users');

      if (response.statusCode == 200) {
        return (response.data as List).map((user) {
          return {
            'id': user['id'],
            'nickname': user['nickname'],
            'profile_pic': user['profile_pic'],
            'isChecked': false,
            'isPaid': false,
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch users for trip');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getRegionByTripId(int tripId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get('$baseUrl/trip/$tripId/region');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch region');
      }
    } catch (e) {
      print('Error fetching region: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getTripDetails(int tripId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get('$baseUrl/trip/$tripId/details');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch trip details');
      }
    } catch(e) {
      print('Error fetching trip details: $e');
      throw Exception('Error: $e');
    }
  }

}