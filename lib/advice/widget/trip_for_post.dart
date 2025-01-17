import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/model/json_parser.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/trip/model/trip_day_model.dart';
import 'package:flutter_locatrip/trip/model/trip_model.dart';

class TripForPost extends StatefulWidget {
  Function(String) onTripDataValue;
  int tripId;

  TripForPost({super.key, required this.tripId, required this.onTripDataValue});

  @override
  State<TripForPost> createState() => _TripForPostState();
}

class _TripForPostState extends State<TripForPost> {
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
    _initTripSchedules(widget.tripId);
  }

  void _initTripSchedules(int tripId) async {
    try {
      List<Map<String, dynamic>> results =
          await _tripDayModel.getTripDay(widget.tripId, context);
      int day = 1;
      for (int i = 0; i < results.length; i++) {
        if (i > 0 && results[i - 1]["date"] == results[i]["date"]) {
          continue;
        } else {
          String tripDay = "day ${day++}";
          String tripDate = results[i]["date"];

          _days.add({"day": tripDay, "date": tripDate});
        }

        setState(() {
          _myTrip = results;
          _days;
          _schedules = _myTrip.where((trip) => trip["dateIndex"] == (selectedIndex + 1)).toList();
        });
      }

      widget.onTripDataValue(_jsonParser.convertToJSONString(_myTrip));
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
                                _schedules = _myTrip.where((trip) => trip["dateIndex"] == (selectedIndex + 1)).toList();
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
                            margin: EdgeInsets.all(16),
                            width: MediaQuery.of(context).size.width,
                            child: Row(children: [
                              CircleAvatar(
                                backgroundColor: pointBlueColor,
                                child: Text("${index + 1}",
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white)),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 16),
                                height: 70,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                    boxShadow: [BoxShadow(color: lightGrayColor, blurRadius: 4)],
                                    color: Colors.white),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Text(
                                            "${_schedules[index]["location"]["name"]}",
                                            style: Theme.of(context).textTheme.titleMedium)),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                            "${_schedules[index]["location"]["category"]} · ${_schedules[index]["location"]["address"]}",
                                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grayColor)))
                                  ],
                                ),
                              ))
                            ]));
                      }),
                )
                // 메모숨기기 아직 넣지마
              ]));
  }
}
