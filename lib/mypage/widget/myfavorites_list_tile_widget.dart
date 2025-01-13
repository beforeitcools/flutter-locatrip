import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:flutter_locatrip/map/model/place.dart';
import 'package:flutter_locatrip/map/model/toggle_favorite.dart';

class MyfavoritesListTileWidget extends StatelessWidget {
  final int selectedIndex;
  final List<dynamic> myFavorites;
  final Function(bool isFavorite, Place place) updateFavoriteStatus;
  final Future<void> Function(Place place, bool isFavorite)
      toggleFavoriteStatus;

  const MyfavoritesListTileWidget({
    super.key,
    required this.selectedIndex,
    required this.myFavorites,
    required this.updateFavoriteStatus,
    required this.toggleFavoriteStatus,
  });

  Widget _listTileCreator(int index, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // 장소 상세 페이지 또는 게시글 페이지로 연결
        onTap: () =>
            {} /*navigateToTripViewScreen(myTrips[selectedIndex][index]['tripId'])*/,
        splashColor: Color.fromARGB(50, 43, 192, 228),
        highlightColor: Color.fromARGB(30, 43, 192, 228),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      myFavorites[selectedIndex][index]['title'],
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSansKR',
                      ),
                      overflow: TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    selectedIndex == 0
                        ? Text(
                            "${myFavorites[selectedIndex][index]['address']}",
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow:
                                TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                            maxLines: 1,
                          )
                        : Text(
                            "${myFavorites[selectedIndex][index]['nickname']}님의 일정  • ${myFavorites[selectedIndex][index]['startDate']} ~ ${myFavorites[selectedIndex][index]['endDate']}",
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow:
                                TextOverflow.ellipsis, // 텍스트 삐져나옴 방지(길면...)
                            maxLines: 1,
                          ),
                  ],
                ),
              ),
              SizedBox(
                width: 16,
              ),
              /*IconButton(
                onPressed: () {
                  _toggleFavorite.toggleFavoriteStatus(
                      place,
                      isFavorite,
                      // _favoriteStatus,
                      // _favoriteStatusList,
                      context,
                      () => _updateFavoriteStatus(
                          !(_favoriteStatus[_nearByPlacesList[index].name] ??
                              false),
                          _nearByPlacesList[index]));
                },
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_outline_outlined,
                  color: isFavorite ? Colors.red : null,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (myFavorites.isNotEmpty && myFavorites[selectedIndex].isNotEmpty) {
      return Column(
        children: List.generate(
          myFavorites[selectedIndex].length,
          (index) => _listTileCreator(index, context),
        ),
      );
    } else if (selectedIndex == 0) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: Text("저장된 장소가 없습니다."),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: Text("저장된 게시글이 없습니다."),
        ),
      );
    }
  }
}
