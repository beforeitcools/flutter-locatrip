import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/map/screen/location_detail_screen.dart';

import '../../map/model/place.dart';

class LocationBottomSheet extends StatefulWidget {
  final Place place;
  const LocationBottomSheet({super.key, required this.place});

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LocationDetailScreen(place: widget.place)));
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 15),
                minimumSize: Size.fromHeight(0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.place.name ?? "",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Row(
                        children: [
                          Text(
                            widget.place.category ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: grayColor),
                          ),
                          if (widget.place.category != null &&
                              widget.place.address != null)
                            Text(
                              "·",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: grayColor),
                            ),
                          Text(
                            widget.place.address.split(" ")[0] ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: grayColor),
                          ),
                        ],
                      )
                    ],
                  ),
                  Icon(Icons.chevron_right, color: blackColor)
                ],
              )),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    minimumSize: Size.fromHeight(0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: grayColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "시간 추가",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: grayColor),
                      )
                    ],
                  )),
              TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    minimumSize: Size.fromHeight(0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 18,
                        color: grayColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "메모 추가",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: grayColor),
                      )
                    ],
                  )),
              TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    minimumSize: Size.fromHeight(0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 18,
                        color: grayColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "비용 추가",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: grayColor),
                      )
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
