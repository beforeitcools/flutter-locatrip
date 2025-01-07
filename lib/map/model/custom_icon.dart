import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomIcon {
  final String iconMaskBaseUri;
  final String iconBackgroundColor;

  CustomIcon(
      {required this.iconMaskBaseUri, required this.iconBackgroundColor});

  /*Future<BitmapDescriptor> getBitmapDescriptor() async {
    String iconSvgUri = "$iconMaskBaseUri.svg";

    try {
      // SVG 이미지를 로드합니다.
      final svgPicture = SvgPicture.network(iconSvgUri);

      // RepaintBoundary 위젯을 생성합니다.
      final boundary = GlobalKey();

      // 캡처할 컨테이너를 만들고, RepaintBoundary로 감쌉니다.
      final container = Container(
        key: boundary,
        width: 100, // 원하는 크기 설정
        height: 100, // 원하는 크기 설정
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              color:
                  Color(int.parse(iconBackgroundColor.substring(1), radix: 16)),
            ),
            svgPicture,
          ],
        ),
      );

      // 위젯을 렌더링한 후, RepaintBoundary에서 RenderObject를 찾습니다.
      // addPostFrameCallback을 사용하여 화면 렌더링이 완료된 후 처리합니다.
      final completer = Completer<BitmapDescriptor>();

      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        final RenderRepaintBoundary boundaryRenderObject =
            boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary;

        // 캡처된 이미지를 바이트로 변환
        final image = await boundaryRenderObject.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        // BitmapDescriptor로 변환하여 반환
        completer.complete(BitmapDescriptor.fromBytes(bytes));
      });

      // 결과를 기다립니다.
      return completer.future;
    } catch (e) {
      print("Icon conversion failed: $e");
      rethrow;
    }
  }*/
}
