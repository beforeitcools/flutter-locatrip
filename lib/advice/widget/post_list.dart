import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/post_view_screen.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class PostList extends StatelessWidget {
  final List<dynamic> filteredPost;

  const PostList({
    super.key,
    required this.filteredPost,
  });

  @override
  Widget build(BuildContext context) {
    return filteredPost.isEmpty
        ? Row(
            children: [
              SizedBox(
                width: 16,
              ),
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
                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          // 포스트 페이지로 연결(postId)
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostViewScreen(
                                        postId: post['postId'])));
                          },
                          splashColor: Color.fromARGB(50, 43, 192, 228),
                          highlightColor: Color.fromARGB(30, 43, 192, 228),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 8, 16, 8),
                            child: Column(children: [
                              ListTile(
                                  // 프로필 이미지
                                  leading: post['profilePic'] != null
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: post['profilePic'],
                                            placeholder: (context, url) =>
                                                SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
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
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${post['nickname']}님의 일정 • ${post['selectedRegionsList'][0]} • ${post['startDate']}~${post['endDate']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                            fontSize: 10, color: grayColor),
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
                                    ),
                            ]),
                          ),
                        ),
                      ),
                      if (index != filteredPost.length - 1)
                        Container(
                          height: 1,
                          color: lightGrayColor,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        )
                    ],
                  );
                }),
          );
  }
}
