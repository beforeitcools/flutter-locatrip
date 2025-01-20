import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final double height; // The height of the dotted line
  final Color color; // The color of the dots
  final double dotWidth; // The width of each dot
  final double dotHeight; // The height of each dot
  final double spacing; // The spacing between each dot

  const DottedLine({
    super.key,
    required this.height,
    required this.color,
    required this.dotWidth,
    required this.dotHeight,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: List.generate(
        (height / (dotHeight + spacing)).ceil(),
        (index) => Container(
          width: dotWidth,
          height: dotHeight,
          color: index.isEven ? color : Colors.transparent, // Dots and spacing
        ),
      ),
    );
  }
}
