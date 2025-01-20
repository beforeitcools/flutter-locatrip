class LocalAreaAuthController {
  final int _expirationPeriod = 30;

  // 남은 유효기간을 계산해주는 함수
  int calculateDaysLeftUntilExpiration(List<dynamic> localAreaAuthDate) {
    DateTime authDate = DateTime(
      localAreaAuthDate[0], // year
      localAreaAuthDate[1], // month
      localAreaAuthDate[2], // day
      localAreaAuthDate[3], // hour
      localAreaAuthDate[4], // minute
      localAreaAuthDate[5], // second
    );

    // 유효기간은 private int로 여기서 관리
    DateTime expirationDate = authDate.add(Duration(days: _expirationPeriod));
    int daysLeft = expirationDate.difference(DateTime.now()).inDays;

    // 음수 또는 0 은 0으로
    return daysLeft > 0 ? daysLeft : 0;
  }

  // alert 가 보이는 페이지 무조건 써야 하는 함수
  // 남은 유효기간 계산해서 n일 이하면 user_alarm 테이블에 insert
  // insert 전에 해당 알림 있는지 확인(id: 4, is_read: 0, user_id: 본인)

  // 행정구역명에서(광역시,특별시,특례시,시,군)
  /*static String calculateDaysLeftUntilExpiration(
      List<dynamic> localAreaAuthDate) {
    DateTime authDate = DateTime(
      localAreaAuthDate[0], // year
      localAreaAuthDate[1], // month
      localAreaAuthDate[2], // day
      localAreaAuthDate[3], // hour
      localAreaAuthDate[4], // minute
      localAreaAuthDate[5], // second
    );

    // 유효기간은 private int로 여기서 관리
    DateTime expirationDate = authDate.add(Duration(days: _expirationPeriod));
    int daysLeft = expirationDate.difference(DateTime.now()).inDays;

    // 음수 또는 0 은 0으로
    return daysLeft > 0 ? daysLeft : 0;
  }*/
}
