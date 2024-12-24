import 'package:flutter/material.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     fit: BoxFit.cover,
        //     image: AssetImage('assets/bg-1.jpg'),
        //   ),
        // ),
        child: Column(
          children: [
            Image(
              image: AssetImage('assets/bg-1.jpg'),
            ),
            Container(
              padding: EdgeInsets.only(top: 24, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.close,
                    ),
                  ),
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
      ),
    );
  }
}
