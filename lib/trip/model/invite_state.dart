import 'package:flutter/material.dart';

class InviteState extends ChangeNotifier {
  int? _inviteId; // 초대ID
  int? _hostId; // 호스트ID

  int? get inviteId => _inviteId;

  int? get hostId => _hostId;

  // 초대ID 설정
  void setInviteId(int? inviteId) {
    _inviteId = inviteId;
    notifyListeners(); // 상태 변경 알리기
  }

  // 사용자ID 설정
  void setHostId(int? hostId) {
    _hostId = hostId;
    notifyListeners(); // 상태 변경 알리기
  }
}
