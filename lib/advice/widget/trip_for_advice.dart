import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/model/json_parser.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/trip_day_model.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';

class TripForAdvice extends StatefulWidget {
  String tripData;

  TripForAdvice({super.key, required this.tripData});

  @override
  State<TripForAdvice> createState() => _TripForPostState();
}

class _TripForPostState extends State<TripForAdvice> {
  TripModel _tripModel = TripModel();
  TripDayModel _tripDayModel = TripDayModel();
  JsonParser _jsonParser = JsonParser();

  int selectedIndex = 0;

  late List<Map<String, dynamic>> _myTrip = [];
  late List<Map<String, String>> _days = [];
  late dynamic _schedules = [];

  @override
  void initState() {
    super.initState();
    print('여기가 문제지 initstate');
    _myTrip = _jsonParser.convertToList(widget.tripData);
    _initTripSchedules();
  }

  void _initTripSchedules() async {
    try {
      int day = 1;
      for (int i = 0; i < _myTrip.length; i++) {
        if(_days.isNotEmpty){
          for(var d in _days){
            if(d["date"] == _myTrip[i]["date"]) { continue; }
            else{
              String tripDay = "day ${day++}";
              String tripDate = _myTrip[i]["date"];

              _days.add({"day": tripDay, "date": tripDate});
              print('my days: $_days');
            }
          }
        }
        else{
          String tripDay = "day ${day++}";
          String tripDate = _myTrip[i]["date"];

          _days.add({"day": tripDay, "date": tripDate});
          print('my days: $_days');
        }

      }
    } catch (e) {
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
        child: _days.isEmpty
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Column(children: [
          SizedBox(
            height: 52,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedIndex;
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          _schedules = _myTrip.where((trip) => trip["dateIndex"] == (selectedIndex)).toList();
                        });
                      },
                      child: Container(
                        width: 91,
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? pointBlueColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: isSelected ? Colors.transparent : grayColor, width: 1)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_days[index]["day"]!,
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(color: isSelected ? Colors.white : grayColor)),
                            Text(_days[index]["date"]!,
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(color: isSelected ? Colors.white : grayColor))
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
                Text(_days[selectedIndex]["day"]!,
                    style: Theme.of(context).textTheme.labelLarge),
                SizedBox(width: 10),
                Text(_days[selectedIndex]["date"]!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: grayColor))
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Row(children: [
                        CircleAvatar(
                          backgroundColor: pointBlueColor,
                          child: Text("${index + 1}",
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white)),
                        ),
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 16),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 16),
                              height: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                  boxShadow: [BoxShadow(color: lightGrayColor, blurRadius: 4)],
                                  color: Colors.white),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("${_schedules[index]["location"]["name"]}",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleMedium),
                                        Text("${_schedules[index]["location"]["category"]} · ${_schedules[index]["location"]["address"]}",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grayColor))],),
                                    IconButton(onPressed: (){/*TODO 바텀바로 첨삭보기, 첨삭하기(현지인의 경우)*/}, icon: Icon(Icons.forum_outlined), color: blackColor,)
                              ])
                            ))
                      ]));
                }),
          )
          // 메모숨기기 아직 넣지마
        ]));
  }
}
