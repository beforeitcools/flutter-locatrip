import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../common/widget/color.dart';

class DeniedPermissionDialog extends StatefulWidget {
  const DeniedPermissionDialog({super.key});

  @override
  State<DeniedPermissionDialog> createState() => _DeniedPermissionDialogState();
}

class _DeniedPermissionDialogState extends State<DeniedPermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        '위치 권한 필요',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
      ),
      content: Text(
        '지도를 표시하려면 위치 권한이 필요합니다. 설정에서 권한을 부여해주세요.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '닫기',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: grayColor),
          ),
        ),
        TextButton(
          onPressed: () {
            Geolocator.openAppSettings();
            Navigator.pop(context);
          },
          child: Text(
            '설정으로 이동',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: pointBlueColor),
          ),
        ),
      ],
    );
  }
}
