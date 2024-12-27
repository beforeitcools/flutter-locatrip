import 'package:flutter/material.dart';

import '../../common/widget/color.dart';
import '../widget/selected_regions.dart';

class CreateTripScreen extends StatefulWidget {
  final List<Map<String, String>> selectedRegions;
  final String defaultImageUrl;
  final bool isAbled;
  const CreateTripScreen(
      {super.key,
      required this.selectedRegions,
      required this.defaultImageUrl,
      required this.isAbled});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
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
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: EdgeInsets.fromLTRB(16, 25, 16, 0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    Row(
                      children: [
                        ...selectedRegions.map((region) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
                            child: Column(
                              children: [
                                //image 위에 x버튼
                                ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12), // 이미지 둥글게
                                    child: Image.asset(
                                      region["imageUrl"].toString() ??
                                          defaultImageUrl,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          defaultImageUrl,
                                          width: 50,
                                          height: 50,
                                        );
                                      },
                                    )),
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
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "여행 제목",
                      ),
                    ),
                  ]),
                ),
                SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        minimumSize: Size(100, 56), // 최소 높이 설정
                        backgroundColor:
                            !isAbled ? lightGrayColor : pointBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 둥근 테두리 설정
                        ),
                      ),
                      child: Text(
                        "일정 생성",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      )),
                ),
              ],
            )));
  }
}
