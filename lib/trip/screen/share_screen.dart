import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ShareScreen extends StatefulWidget {
  final String title;
  final int num;
  final VoidCallback share;
  const ShareScreen(
      {super.key, required this.title, required this.num, required this.share});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox.shrink(),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(3), minimumSize: Size(0, 0)),
              child: Icon(
                Icons.close,
                color: blackColor,
              ))
        ],
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "여행친구",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.num.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: pointBlueColor),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "함께 여행갈 친구나 가족을 초대해보세요.",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: grayColor),
              ),
              Text("여행 일정을 함께 계획할 수 있습니다. (최대 15명)",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: grayColor)),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: widget.share,
                      style: TextButton.styleFrom(
                        minimumSize: Size((screenWidth - 48) / 2, 0),
                        backgroundColor: Color(0xfffee500),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/kakao_logo.png",
                            scale: 1.4,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "카카오톡 초대",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          )
                        ],
                      )),
                  TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        minimumSize: Size((screenWidth - 48) / 2, 0),
                        backgroundColor: pointBlueColor,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text("초대 링크 복사",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white))
                        ],
                      ))
                ],
              )
            ],
          )),
    );
  }
}
