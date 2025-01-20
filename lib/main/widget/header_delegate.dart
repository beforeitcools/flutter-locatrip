import 'package:flutter/material.dart';

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  HeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      // elevation: 4, // 헤더에 약간의 그림자 추가
      color: Colors.transparent, // 배경 투명
      child: child,
    );
  }

  @override
  double get maxExtent => 90.0; // 헤더의 최대 높이

  @override
  double get minExtent => 90.0; // 헤더의 최소 높이 (스크롤 시 유지)

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // 항상 다시 빌드
  }
}
