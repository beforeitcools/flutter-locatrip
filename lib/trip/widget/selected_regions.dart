import 'package:flutter/material.dart';

import '../../common/widget/color.dart';

class SelectedRegions extends StatefulWidget {
  final List<Map<String, String>> selectedRegions;
  final String defaultImageUrl;
  final bool isAbled;
  const SelectedRegions(
      {super.key,
      required this.selectedRegions,
      required this.defaultImageUrl,
      required this.isAbled});

  @override
  State<SelectedRegions> createState() => selectedRegionsState();
}

class selectedRegionsState extends State<SelectedRegions> {
  late List<Map<String, String>> selectedRegions;
  late String defaultImageUrl;
  late bool isAbled;

  @override
  void initState() {
    super.initState();
    selectedRegions = widget.selectedRegions;
    defaultImageUrl = widget.defaultImageUrl;
    isAbled = widget.isAbled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...selectedRegions.map((region) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
            child: Column(
              children: [
                //image 위에 x버튼
                Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12), // 이미지 둥글게
                        child: Image.asset(
                          region["imageUrl"].toString() ?? defaultImageUrl,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              defaultImageUrl,
                              width: 50,
                              height: 50,
                            );
                          },
                        )),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: Offset(1, 0),
                                blurRadius: 2,
                              )
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.close, size: 12, color: grayColor),
                            onPressed: () {
                              setState(() {
                                selectedRegions.remove(region);
                                if (selectedRegions.isEmpty) isAbled = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  region["name"].toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: grayColor),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
