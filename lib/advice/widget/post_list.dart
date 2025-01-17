import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostList extends StatelessWidget {
  final List<dynamic> filteredPost;

  const PostList({
    super.key,
    required this.filteredPost,
  });
  /*List<Map<String, String>> posts = [
    {
      'title': '친구와 경주 1박2일 뚜벅이 여행',
      'author': 'namjoon님의 일정',
      'date': '2024.12.24~2024.12.26',
      'content':
          '마음맞는 친구와 편안히 보낸 힐링여행 뚜벅이에게 최상의 숙소 위치였던 황리단길 주요 관광지를 방문하기도 좋았고 쇼핑에 식당, 카페도 많아... '
    },
    {
      'title': '친구와 경주 1박2일 뚜벅이 여행',
      'author': 'namjoon님의 일정',
      'date': '2024.12.24~2024.12.26',
      'content':
          '마음맞는 친구와 편안히 보낸 힐링여행 뚜벅이에게 최상의 숙소 위치였던 황리단길 주요 관광지를 방문하기도 좋았고 쇼핑에 식당, 카페도 많아... '
    },
  ];*/

  @override
  Widget build(BuildContext context) {
    return filteredPost.isEmpty
        ? Row(
            children: [
              Text(
                "해당하는 포스트가 없습니다.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          )
        : Expanded(
            child: ListView.builder(
                itemCount: filteredPost.length,
                itemBuilder: (context, index) {
                  final post = filteredPost[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      // 포스트 페이지로 연결(postId)
                      onTap: () {},
                      splashColor: Color.fromARGB(50, 43, 192, 228),
                      highlightColor: Color.fromARGB(30, 43, 192, 228),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: lightGrayColor))),
                        child: Column(children: [
                          ListTile(
                              // 프로필 이미지
                              leading: post['profilePic'] != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: post['profilePic'],
                                        placeholder: (context, url) => SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error_outline,
                                          size: 28,
                                        ),
                                        fit: BoxFit.cover,
                                        width: 60,
                                        height: 60,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                              'assets/default_profile_image.png')
                                          as ImageProvider),
                              title: Text(
                                post["title"],
                                style: Theme.of(context).textTheme.labelLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${post['nickname']}님의 일정 • ${post['selectedRegionsList'][0]} • ${post['startDate']}~${post['endDate']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(fontSize: 10, color: grayColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                          post['content'] != null
                              ? Container(
                                  padding: EdgeInsets.only(left: 16),
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    post['content'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: grayColor),
                                  ))
                              : SizedBox(
                                  height: 40,
                                )
                        ]),
                      ),
                    ),
                  );
                }),
          );
  }
}
