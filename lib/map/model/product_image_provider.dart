import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

class ProductsImageProvider extends EasyImageProvider {
  final List<String> photoUrl;
  final int initialIndex;

  ProductsImageProvider({required this.photoUrl, required this.initialIndex});

  @override
  ImageProvider<Object> imageBuilder(BuildContext context, int index) {
    String url = photoUrl[index];
    return NetworkImage(url);
  }

  @override
  int get imageCount => photoUrl.length;
}
