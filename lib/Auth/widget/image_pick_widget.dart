import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/widget/color.dart';

class ImagePickWidget extends StatelessWidget {
  late Function selectImage;
  final ImagePicker _imagePicker = ImagePicker();

  ImagePickWidget({
    super.key,
    required this.selectImage,
  });

  Future<void> _pickImageFromGallery() async {
    XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectImage(pickedFile);
    }
  }

  Future<void> _pickImageFromCamera() async {
    XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      selectImage(pickedFile);
    }
  }

  void _showImagePickDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("사진 선택"),
            actions: [
              TextButton(
                  onPressed: () async {
                    await _pickImageFromGallery();
                    Navigator.pop(context);
                  },
                  child: Text("갤러리에서 선택")),
              TextButton(
                  onPressed: () async {
                    await _pickImageFromCamera();
                    Navigator.pop(context);
                  },
                  child: Text("사진 촬영")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 4,
      child: GestureDetector(
        onTap: () => _showImagePickDialog(context),
        child: Opacity(
          opacity: 0.7,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              color: grayColor,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}
