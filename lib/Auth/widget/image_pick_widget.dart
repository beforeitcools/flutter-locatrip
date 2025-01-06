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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "사진 선택",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: blackColor),
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await _pickImageFromGallery();
                            Navigator.pop(context);
                          },
                          splashColor: Color.fromARGB(50, 43, 192, 228),
                          highlightColor: Color.fromARGB(30, 43, 192, 228),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 150,
                            height: 48,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: lightGrayColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                )),
                            child: Text(
                              "갤러리에서 선택",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: blackColor),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await _pickImageFromCamera();
                            Navigator.pop(context);
                          },
                          splashColor: Color.fromARGB(50, 43, 192, 228),
                          highlightColor: Color.fromARGB(30, 43, 192, 228),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 150,
                            height: 48,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: lightGrayColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                )),
                            child: Text(
                              "사진 촬영",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: blackColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
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
