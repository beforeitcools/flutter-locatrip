import 'package:flutter/material.dart';

class TripInviteScreen extends StatefulWidget {
  // final String tripId;
  const TripInviteScreen({
    super.key,
    // required this.tripId
  });

  @override
  State<TripInviteScreen> createState() => _TripInviteScreenState();
}

class _TripInviteScreenState extends State<TripInviteScreen> {
  late int _tripId;

  @override
  void initState() {
    super.initState();

    // _tripId = widget.tripId as int;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(onPressed: () {}, child: Text("test")),
    );
  }
}
