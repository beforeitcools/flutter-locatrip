import 'package:flutter/material.dart';
import 'package:flutter_locatrip/mypage/model/mypage_model.dart';

class TogglePostFavorite {
  final MypageModel _mypageModel = MypageModel();

  Future<void> insertFavoritePost(
      BuildContext context, int postId, VoidCallback onUpdate) async {
    try {
      dynamic result = await _mypageModel.insertFavoritePost(context, postId);
      print('좋아요 insert result : $result');

      if ((result != null && result is Map<String, dynamic>)) {
        onUpdate();
      }
    } catch (e) {
      print('에러메세지 : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("게시글 좋아요 업데이트중 오류가 발생했습니다: $e")),
      );
    }
  }

  Future<void> removeFavoritePost(
      BuildContext context, int postId, VoidCallback onUpdate) async {
    try {
      String result = await _mypageModel.deleteFavoritePost(context, postId);
      print('좋아요 delete result : $result');

      if (result.contains("성공")) {
        onUpdate();
      }
    } catch (e) {
      print('에러메세지 : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("게시글 좋아요 삭제중 오류가 발생했습니다: $e")),
      );
    }
  }

  void toggleFavoriteStatus(bool isFavorite, int postId, BuildContext context,
      VoidCallback onUpdate) {
    // bool _isFavorite = isFavorite ?? false;
    print('현재 상태: $isFavorite');

    if (isFavorite) {
      removeFavoritePost(context, postId, onUpdate);
    } else {
      insertFavoritePost(context, postId, onUpdate);
    }
  }
}
