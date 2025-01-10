import 'package:flutter/material.dart';

class ErrorTextWidget extends StatelessWidget {
  final String? errorMessage;

  const ErrorTextWidget({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Text(
      errorMessage ?? '',
      style: _getTextStyle(context, errorMessage),
    );
  }

  TextStyle? _getTextStyle(BuildContext context, String? error) {
    switch (error) {
      case String e when e.contains("형식"):
        return Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.red);
      case String e when e.contains("특수문자"):
        return Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.red);
      case String e when e.contains("중복"):
        return Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.red);
      case String e when e.contains("사용 가능한"):
        return Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.green);
    }
  }
}
