import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class LocalAreaAuthScreen extends StatefulWidget {
  const LocalAreaAuthScreen({super.key});

  @override
  State<LocalAreaAuthScreen> createState() => _LocalAreaAuthScreenState();
}

class _LocalAreaAuthScreenState extends State<LocalAreaAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 다른데 누르면 키보드 감춤
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("현지인 인증하기",
              style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 165,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "현재 위치로 현지인 인증하기",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                              ),
                            ],
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size(380, 60),
                            backgroundColor: pointBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
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
