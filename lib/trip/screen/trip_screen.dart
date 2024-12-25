import 'package:flutter/material.dart';

import '../widget/selectPlaceBottomSheet.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      // ),
      backgroundColor: Colors.transparent,
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/bg-1.jpg'),
            ),
          ),
          child: GestureDetector(
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
                          //borderRadius: BorderRadius.circular(100),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "/home");
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
                    // 텍스트를 가운데로 정렬
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
