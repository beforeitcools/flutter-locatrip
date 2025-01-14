import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Returns a generated png image in [ByteData] format with the requested size.
Future<ByteData> createCustomMarkerIconImage(
    {required Size size, required String text, required Color color}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final _MarkerPainter painter = _MarkerPainter(text, color);

  painter.paint(canvas, size);

  final ui.Image image = await recorder
      .endRecording()
      .toImage(size.width.floor(), size.height.floor());

  final ByteData? bytes =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!;
}

class _MarkerPainter extends CustomPainter {
  final String text;
  final Color color;

  _MarkerPainter(this.text, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2), // 원의 중심
      radius,
      paint,
    );
    // Prepare text to draw
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Center the text
    final Offset textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_MarkerPainter oldDelegate) => false;
}
