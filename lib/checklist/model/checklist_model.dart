import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/Auth/auth_dio_interceptor.dart';
import 'package:flutter_locatrip/common/widget/url.dart';

class ChecklistModel {
  final dio = Dio();
  final String baseUrl = "$backUrl/api/checklist";


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

  // 기본 카테고리가 이미 존재하는지 확인하는 메소드
  Future<bool> checkIfDefaultCategoriesExist(int tripId, int userId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try{
      final response = await dio.get(
        "$baseUrl/categories",
        queryParameters: {
          'tripId' : tripId,
          'userid' : userId,
        },
      );

      if (response.statusCode == 200) {
        var categories = response.data as List<dynamic>;

        bool hasDefaultCategory = categories.any((category) =>
        (category['name'] == '필수 준비물' || category['name'] == '기본 짐싸기') &&
            (category['status'] == 1 || category['status'] == 0)); // 둘 다 포함
        return hasDefaultCategory;
      } else {
        throw Exception("카테고리 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<void> addDefaultCategories(int tripId, int userId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      bool categoriesExist = await checkIfDefaultCategoriesExist(tripId, userId, context);
      if (categoriesExist) {
        print("기본 카테고리가 이미 존재합니다.");
        return;
      }

      List<Map<String, dynamic>> defaultCategories = [
        {'name': '필수 준비물', 'tripId': tripId, 'userId': userId, 'status': 1},
        {'name': '기본 짐싸기', 'tripId': tripId, 'userId': userId, 'status': 1},
      ];

      for (var category in defaultCategories) {
        await dio.post(
          "$baseUrl/categories/insert",
          data: category,
        );
      }
    } catch(e) {
      print('디폴트 카테고리 추가 실패 : $e');
      throw Exception("Error: $e");
    }
  }

  Future<String> addCategory(Map<String, dynamic> categoryData, BuildContext context) async{
    dio.interceptors.add(AuthInterceptor(dio, context));
    try{
      final response = await dio.post(
          "$baseUrl/categories/insert",
          data: categoryData
      );

      if (response.statusCode == 200) {
        return "카테고리가 추가되었습니다.";
      } else {
        return "카테고리 추가 실패";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<List<dynamic>> getCategories(BuildContext context) async{
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get("$baseUrl/categories");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("카테고리 로드 실패");
      }
    } catch(e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<void> deleteCategory(int categoryId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try{
      final response = await dio.delete(
        "$baseUrl/categories/delete",
        data: {'categoryId' : categoryId},
      );
      if (response.statusCode == 200) {
        print("카테고리 삭제 완료");
      } else {
        throw Exception("카테고리 삭제 실패");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("삭제 실패: $e");
    }
  }

  Future<void> deleteItems(List<int> itemIds, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try{
      final response = await dio.delete(
        "$baseUrl/items/delete",
        data: {'itemIds': itemIds},
      );

      if (response.statusCode == 200) {
        print ("선택한 항목이 삭제되었습니다.");
      } else {
        throw Exception("항목 삭제 실패");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("삭제 실패: $e");
    }
  }

  Future<List<dynamic>> getItemsByCategory(int categoryId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get("$baseUrl/categories/$categoryId/items");

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("항목 로드 실패");
      }
    } catch (e) {
      print (e);
      throw Exception ("Error : $e");
    }
  }

  Future<String> addItemToCategory(int categoryId, Map<String, dynamic> itemData, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.post(
        "$baseUrl/categories/$categoryId/items",
        data: itemData,
      );

      if (response.statusCode == 200) {
        return "항목이 추가되었습니다.";
      } else {
        return "항목 추가 실패";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<void> updateCategory(
      int categoryId, String newName, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.post(
        "$baseUrl/categories/update",
        data: {
          'categoryId': categoryId,
          'name': newName,
        },
      );

      if (response.statusCode == 200) {
        print("카테고리가 수정되었습니다.");
      } else {
        throw Exception("카테고리 수정 실패");
      }
    } catch (e) {
      print("카테고리 수정 중 오류 발생: $e");
      throw Exception("Error: $e");
    }
  }

  Future<void> updateItem(int itemId, String newName, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.post(
        "$baseUrl/items/update",
        data: {
          'itemId': itemId,
          'name': newName,
        },
      );

      if (response.statusCode == 200) {
        print("아이템이 수정되었습니다.");
      } else {
        throw Exception("아이템 수정 실패");
      }
    } catch (e) {
      print("아이템 수정 중 오류 발생: $e");
      throw Exception("Error: $e");
    }
  }

  Future<String> updateItemCheckedStatus(int itemId, bool isChecked, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.post(
        "$baseUrl/items/$itemId/check",
        data: isChecked,
        options: Options(
          headers: {'Content-Type' : 'application/json'},
        ),
      );

      if (response.statusCode == 204) {
        return "체크 상태가 업데이트되었습니다.";
      } else {
        return "체크 상태 업데이트 실패";
      }
    } catch (e) {
      print(e);
      throw Exception("Error : $e");
    }
  }

  Future<String> getTripDuration(int tripId, BuildContext context) async {
    dio.interceptors.add(AuthInterceptor(dio, context));
    try {
      final response = await dio.get("$baseUrl/trip/$tripId/duration");
      if (response.statusCode == 200) {
        return response.data as String;
      }
    else {
    throw Exception('Failed to fetch trip duration');
    }
  } catch (e) {
      print('Error fetching region: $e');
      throw Exception('Error: $e');
    }
  }

}