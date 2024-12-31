import 'package:dio/dio.dart';

class ChecklistModel {
  final dio = Dio();
  final String baseUrl = "http://localhost:8082/api/checklist";

  Future<List<dynamic>> getCategories() async{
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

  Future<String> addCategory(Map<String, dynamic> categoryData) async{
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

  Future<void> deleteCategory(int categoryId) async {
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

  Future<void> deleteItems(List<int> itemIds) async {
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

  Future<List<dynamic>> getItemsByCategory(int categoryId) async {
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

  Future<String> addItemToCategory(int categoryId, Map<String, dynamic> itemData) async {
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

  Future<String> updateItemCheckedStatus(int itemId, bool isChecked) async {
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

}