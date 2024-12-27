import 'package:flutter/material.dart';
import 'package:flutter_locatrip/trip/model/date_range_model.dart';

class TripViewScreen extends StatefulWidget {
  /*final DateRangeModel dateRangeModel;
  final String title;
  final List<Map<String, String>> selectedRegions;*/

  const TripViewScreen({
    super.key,
    /*required this.selectedRegions,
      required this.dateRangeModel,
      required this.title*/
  });

  @override
  State<TripViewScreen> createState() => _TripViewScreenState();
}

class _TripViewScreenState extends State<TripViewScreen> {
/*  late DateRangeModel dateRangeModel;
  late String title;
  late List<Map<String, String>> selectedRegions;*/

  @override
  void initState() {
    super.initState();
/*
    dateRangeModel = widget.dateRangeModel;
    title = widget.title;
    selectedRegions = widget.selectedRegions;*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.ios_share)),
            IconButton(
                onPressed: () {}, icon: Icon(Icons.notifications_outlined)),
          ],
        ),
        body: Column(
          children: [
            Column(
              children: [
                Row(
                  children: [TextButton(onPressed: () {}, child: Text("편집"))],
                )
              ],
            )
          ],
        ));
  }
}
