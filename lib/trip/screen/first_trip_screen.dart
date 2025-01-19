import 'dart:math';

import 'package:flutter/material.dart';

import '../widget/bottom_sheet_content.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late String _randomImage;

  @override
  void initState() {
    super.initState();
// 이미지 리스트
    final List<String> _imageList = [
      'assets/bg/bg-1.jpg',
      'assets/bg/bg-2.jpg',
      'assets/bg/bg-3.jpg',
      'assets/bg/bg-4.jpg',
      'assets/bg/bg-5.jpg',
      'assets/bg/bg-6.jpg',
      'assets/bg/bg-7.jpg',
      'assets/bg/bg-8.jpg',
    ];
    // 랜덤으로 이미지 선택
    final random = Random();
    _randomImage = _imageList[random.nextInt(_imageList.length)];
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.97,
          child: BottomSheetContent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      // ),
      backgroundColor: Colors.transparent,
      body: GestureDetector(
          onTap: () {
            _showBottomSheet(context);
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(_randomImage),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 24, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        width: 34,
                        height: 34,
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            //Navigator.pushReplacementNamed(context, "/home");
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            // size: 24,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "어디로 떠나시나요?",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
