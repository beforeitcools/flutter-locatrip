import 'package:flutter/material.dart';

class ParticipantWidget extends StatelessWidget {
  final String name;
  final bool isSelected;
  final Function(bool?) onChanged;

  const ParticipantWidget({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(name),
      value: isSelected,
      onChanged: onChanged,
    );
  }
}
