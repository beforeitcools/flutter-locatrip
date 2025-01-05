import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostBottomSheet extends StatefulWidget {
  const PostBottomSheet({super.key});

  @override
  State<PostBottomSheet> createState() => _PostBottomSheetState();
}

class _PostBottomSheetState extends State<PostBottomSheet> {

  final List<Map<String, String>> myTripLists = [
    {'title': '부산 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '제주 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '서울 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '광주 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
    {'title': '대전 여행', 'dates': '2024년 12월 24일 - 12월 27일'},
  ];

  List<bool> _isPressed = [];


  @override
  void initState() {
    super.initState();
    _isPressed = List.generate(myTripLists.length, (index)=>false);
  }

  void _updateClickState(int index, bool isPressed){
    setState(() {
      _isPressed[index] = isPressed;
    });
  }
  void _resetState(){
    for(int i = 0; i<_isPressed.length; i++){
      if(_isPressed[i] = true){
        setState(() {
          _isPressed[i] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: (MediaQuery.of(context).size.height * 0.6) - 110,
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("지역 선택", style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: 16),
                Expanded(child: ListView.builder(
                    itemCount: myTripLists.length,
                    itemBuilder: (context, index){
                      final trip = myTripLists[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: lightGrayColor, width: 1)),
                        child: ListTile(
                            onTap: (){ _resetState(); _updateClickState(index, true);},
                            leading: CircleAvatar(backgroundColor: grayColor, child: Icon(Icons.trip_origin, color: subPointColor)),
                            title: Text(trip["title"]!, style: !_isPressed[index] ? Theme.of(context).textTheme.labelMedium : Theme.of(context).textTheme.labelMedium!.copyWith(color: pointBlueColor)),
                            subtitle: Text(trip["dates"]!, style: !_isPressed[index] ? Theme.of(context).textTheme.labelMedium : Theme.of(context).textTheme.labelMedium!.copyWith(color: pointBlueColor)),
                        ),
                      );
                    }))
              ],),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 80), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                backgroundColor: pointBlueColor
            ),
            onPressed: (){}, child: Text("첨삭받기", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white))
          )],
      )),
    );
  }
}

