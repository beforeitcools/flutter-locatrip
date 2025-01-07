import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/Auth/widget/image_pick_widget.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  String? _profileImage;

  @override
  void initState() {
    super.initState();
  }

  /*void _selectImage(XFile pickedFile) {
    setState(() {
      _image = File(pickedFile.path);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 다른데 누르면 키보드 감춤
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text("프로필 수정", style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            child: _profileImage != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: _profileImage!,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.error_outline,
                                        size: 96,
                                      ),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 60,
                                    backgroundImage: AssetImage(
                                            'assets/default_profile_image.png')
                                        as ImageProvider),
                          ),
                          // ImagePickWidget(selectImage: selectImage)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
