import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/subregion_select_filter_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class RegionSelectFilterScreen extends StatefulWidget {
  final Function(String, String) applyFilters;
  final Function(String) regionFilterHandler;
  String selectedRegionFilter;
  String selectedOrderFilter;

  RegionSelectFilterScreen({
    super.key,
    required this.applyFilters,
    required this.regionFilterHandler,
    required this.selectedRegionFilter,
    required this.selectedOrderFilter,
  });

  @override
  State<RegionSelectFilterScreen> createState() =>
      _RegionSelectFilterScreenState();
}

class _RegionSelectFilterScreenState extends State<RegionSelectFilterScreen> {
  late Function(String, String) _applyFilters;
  late Function(String) _regionFilterHandler;
  late String _selectedRegionFilter;
  late String _selectedOrderFilter;
  static const Map<String, List> _regionFilterMapList = {
    "전지역": [],
    "서울": [],
    "부산": [],
    "대구": [],
    "인천": [],
    "광주": [],
    "대전": [],
    "울산": [],
    "세종": [],
    "경기": [
      "수원",
      "성남",
      "안양",
      "안산",
      "용인",
      "부천",
      "광명",
      "평택",
      "과천",
      "의왕",
      "구리",
      "남양주",
      "오산",
      "시흥",
      "군포",
      "의정부",
      "하남",
      "이천",
      "안성",
      "김포",
      "화성",
      "광주",
      "양주",
      "포천",
      "여주",
      "동두천",
      "가평",
      "연천"
    ],
    "강원": [
      "춘천",
      "원주",
      "강릉",
      "동해",
      "태백",
      "속초",
      "삼척",
      "홍천",
      "횡성",
      "영월",
      "평창",
      "정선",
      "철원",
      "화천",
      "양구",
      "인제",
      "고성",
      "양양"
    ],
    "충북": ["청주", "충주", "제천", "보은", "옥천", "영동", "증평", "진천", "괴산", "음성", "단양"],
    "충남": [
      "천안",
      "공주",
      "보령",
      "아산",
      "서산",
      "논산",
      "계룡",
      "당진",
      "금산",
      "부여",
      "서천",
      "청양",
      "홍성",
      "예산",
      "태안"
    ],
    "전북": [
      "전주",
      "군산",
      "익산",
      "정읍",
      "남원",
      "김제",
      "완주",
      "진안",
      "무주",
      "장수",
      "임실",
      "순창",
      "고창",
      "부안"
    ],
    "전남": [
      "목포",
      "여수",
      "순천",
      "나주",
      "광양",
      "담양",
      "곡성",
      "구례",
      "고흥",
      "보성",
      "화순",
      "장흥",
      "강진",
      "해남",
      "영암",
      "무안",
      "함평",
      "영광",
      "장성",
      "완도",
      "진도",
      "신안"
    ],
    "경북": [
      "포항",
      "경주",
      "김천",
      "안동",
      "구미",
      "영주",
      "영천",
      "상주",
      "문경",
      "경산",
      "군위",
      "의성",
      "청송",
      "영양",
      "영덕",
      "청도",
      "고령",
      "성주",
      "칠곡",
      "예천",
      "봉화",
      "울진",
      "울릉"
    ],
    "경남": [
      "창원",
      "진주",
      "통영",
      "사천",
      "김해",
      "밀양",
      "거제",
      "양산",
      "의령",
      "함안",
      "창녕",
      "고성",
      "남해",
      "하동",
      "산청",
      "함양",
      "거창",
      "합천"
    ],
    "제주": ["제주", "서귀포"]
  };

  @override
  void initState() {
    super.initState();
    _applyFilters = widget.applyFilters;
    _regionFilterHandler = widget.regionFilterHandler;
    _selectedRegionFilter = widget.selectedRegionFilter;
    _selectedOrderFilter = widget.selectedOrderFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("지역 선택", style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3, // Adjust the height of buttons
          ),
          itemCount: _regionFilterMapList.length,
          itemBuilder: (context, index) {
            final region = _regionFilterMapList.keys.toList()[index];
            final bool isSelected = _selectedRegionFilter == region;

            return ElevatedButton(
              onPressed: () {
                _regionFilterHandler(region);
                _applyFilters(region, _selectedOrderFilter);
                setState(() {
                  _selectedRegionFilter = region;
                });
                // 시는 navigator.pop 도는 subregion_select_filter_screen 으로
                // length 로 가능할지도
                if (_regionFilterMapList[region]!.isEmpty) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SubRegionSelectFilterScreen(
                              applyFilters: _applyFilters,
                              regionFilterHandler: _regionFilterHandler,
                              selectedRegionFilter: _selectedRegionFilter,
                              selectedOrderFilter: _selectedOrderFilter,
                              subRegionList: _regionFilterMapList[region]!,
                              selectedRegion: region,
                            )),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? pointBlueColor : Colors.white,
                side: BorderSide(
                  color: grayColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: isSelected ? 2 : 0,
              ),
              child: Text(
                region,
                style: Theme.of(context).textTheme.titleMedium,
                /*style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),*/
              ),
            );
          },
        ),
      ),
    );
  }
}
