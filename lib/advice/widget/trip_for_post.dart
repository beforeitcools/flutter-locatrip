import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';

class TripForPost extends StatefulWidget {
  int tripId;
  TripForPost({super.key, required this.tripId});

  @override
  State<TripForPost> createState() => _TripForPostState();
}

class _TripForPostState extends State<TripForPost> {
  TripModel _tripModel = TripModel();

  int selectedIndex = 0;

  final List<Map<String, String>> days = [
    {"day": "day1", "date": "12.24/화"},
    {"day": "day2", "date": "12.25/수"},
    {"day": "day3", "date": "12.26/목"},
    {"day": "day4", "date": "12.27/금"},
  ];

  final List<Map<String, String>> schedules = [
    {"location" : "강남역", "category" : "관광명소", "address" : "서울 강남구"},
    {"location" : "대구역", "category" : "관광명소", "address" : "대구 북구"},
    {"location" : "강남역", "category" : "관광명소", "address" : "서울 강남구"},
    {"location" : "강남역", "category" : "관광명소", "address" : "서울 강남구"},
  ];


  @override
  void initState() {
    super.initState();
    _initTripSchedules(widget.tripId);
  }

  void _initTripSchedules(int tripId) async
  {
    try{
      Map<String, dynamic> result = await _tripModel.selectTrip(widget.tripId, context);
      print('$result');
    }catch(e){
      print("YOU CANNOT GET YOUR TRIPS $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        SizedBox(
          height: 52,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index){
                bool isSelected = index == selectedIndex;
                return GestureDetector(onTap: (){
                  setState(() {
                    selectedIndex = index;
                  });
                },
                    child: Container(
                      width: 91,
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: isSelected ? pointBlueColor : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: isSelected ? Colors.transparent : grayColor, width: 1)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(days[index]["day"]!, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: isSelected ? Colors.white : grayColor)),
                          Text(days[index]["date"]!, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: isSelected ? Colors.white : grayColor))
                        ],
                      ),
                    ));
              }),
       ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(4),
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Row(
            children: [
              Text(days[selectedIndex]["day"]!, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(width: 10),
              Text(days[selectedIndex]["date"]!, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: grayColor))],
          ),
        ),
        SizedBox(height: 12),
        Container(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: schedules.length,
              itemBuilder: (context, index){
                return Container(
                    margin: EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width,
                    child:
                      Row(children: [
                        CircleAvatar(
                          backgroundColor: pointBlueColor,
                          child: Text("${index+1}", style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white)),
                        ),
                        SizedBox(width: 16),
                        Expanded(child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 16),
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              boxShadow: [
                                BoxShadow(color: lightGrayColor, blurRadius: 4)],
                              color: Colors.white
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("${schedules[index]["location"]}", style: Theme.of(context).textTheme.titleMedium)
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("${schedules[index]["category"]} · ${schedules[index]["address"]}", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grayColor))
                              )
                            ],),
                        ))
                  ]));
              }),
        )
        // 메모숨기기 아직 넣지마

      ]),
    );
  }
}
