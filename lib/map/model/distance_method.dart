// 두 지점 간의 거리 계산 함수
import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double radius = 6371; // 지구 반지름 (킬로미터 단위)
  double dLat = degreesToRadians(lat2 - lat1);
  double dLon = degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(degreesToRadians(lat1)) *
          cos(degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return radius * c; // 반환 값은 킬로미터 단위
}

// 도(degree)를 라디안(radian)으로 변환하는 함수
double degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}
