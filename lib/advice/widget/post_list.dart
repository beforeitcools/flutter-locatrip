import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostList extends StatelessWidget {
  PostList({super.key});
  List<Map<String, String>> posts = [
    {
      'title': '친구와 경주 1박2일 뚜벅이 여행',
      'author': 'namjoon님의 일정',
      'date': '2024.12.24~2024.12.26',
      'content': '마음맞는 친구와 편안히 보낸 힐링여행 뚜벅이에게 최상의 숙소 위치였던 황리단길 주요 관광지를 방문하기도 좋았고 쇼핑에 식당, 카페도 많아... '
    },
    {
      'title': '친구와 경주 1박2일 뚜벅이 여행',
      'author': 'namjoon님의 일정',
      'date': '2024.12.24~2024.12.26',
      'content': '마음맞는 친구와 편안히 보낸 힐링여행 뚜벅이에게 최상의 숙소 위치였던 황리단길 주요 관광지를 방문하기도 좋았고 쇼핑에 식당, 카페도 많아... '
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index){
          final post = posts[index];
          return Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: lightGrayColor))
            ),
            child: Column(children: [
              ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person), // 고양이 프로필!!
              ),
                  title: Text(post["title"]!, style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text('${post['author']} • ${post['date']}', style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 10,color: grayColor))),
              Container(
                padding: EdgeInsets.only(left: 16),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topLeft,
                child: Text(post['content']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: grayColor),)),
            ]),
          );
        }));
  }
}
