import 'package:dio/dio.dart';

// 시/군 불러오기
class RegionModel {
  Future<List<Map<String, String>>> searchAllRegions() async {
    final dio = Dio();

    try {
      List<Map<String, String>> allResults = [];

      // 1. 전국 시/도 조회
      final response = await dio.get(
          "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes?regcode_pattern=*00000000");

      if (response.statusCode == 200) {
        final List<dynamic> regcodes = response.data['regcodes'];

        // 전국 시/도 일단 저장
        for (var item in regcodes) {
          allResults.add({
            "name": item['name'],
            "sub": item['name'],
            "imageUrl": "assets/imgPlaceholder.png"
          });
        }

        // 2. '도'로 끝나는 지역 필터링
        final filteredRegions =
            regcodes.where((region) => region['name'].endsWith('도')).toList();

        // 3. 병렬 요청 - 각 '도'에 대한 시/군 조회
        final List<Future<Response>> requests = filteredRegions.map((region) {
          final code = region['code'].substring(0, 2);
          return dio.get(
              "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes?regcode_pattern=${code}*00000");
        }).toList();

        final responses = await Future.wait(requests);

        // 4. 결과 처리 및 구 제외
        for (var res in responses) {
          if (res.statusCode == 200) {
            final filteredData = res.data['regcodes'].where((item) {
              return item['code'].substring(4, 6) == '00';
            }).toList();

            // 5. 데이터 변환 및 추가
            for (var item in filteredData) {
              final subRegion = filteredRegions.firstWhere(
                  (region) =>
                      item['code'].startsWith(region['code'].substring(0, 2)),
                  orElse: () => {"name": "알 수 없음"})['name'];

              allResults.add({
                "name": item['name'],
                "sub": subRegion,
                "imageUrl": "assets/imgPlaceholder.png"
              });
            }
          } else {
            throw Exception("시/군 데이터 로드 실패");
          }
        }

        // 6. 중복 제거 (name 기준)
        final uniqueResults = allResults
            .fold<Map<String, Map<String, String>>>({}, (map, item) {
              final String fullName = item['name'] ?? "알 수 없음";

              // ex. 경기도 과천시 이면 과천 으로 변경
              final String formattedName = fullName.split(' ').length > 1
                  ? fullName.split(' ')[1].replaceAll(RegExp(r'(시|군|구)$'), '')
                  : fullName; // 시군구 제거

              map[formattedName] = {
                "name": formattedName,
                "sub": item['name']!.split(' ')[0], // 앞단어 만 남기기
                "imageUrl": "assets/ imgPlaceholder.png"
              };
              return map;
            })
            .values
            .toList();

        return uniqueResults;
      } else {
        throw Exception("광역시/도 데이터 로드 실패");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }
}
