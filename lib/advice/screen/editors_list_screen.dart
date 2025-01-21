import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/model/advice_model.dart';
import 'package:flutter_locatrip/common/widget/loading_screen.dart';

import '../../common/screen/userpage_screen.dart';

class EditorsListScreen extends StatefulWidget {
  final int postId;
  const EditorsListScreen({super.key, required this.postId});

  @override
  State<EditorsListScreen> createState() => _EditorsListScreenState();
}

class _EditorsListScreenState extends State<EditorsListScreen> {
  late int _postId;
  bool _isLoading = true;
  final AdviceModel _adviceModel = AdviceModel();
  late List<dynamic> _advicers = [];

  Future<void> _loadAdvisersData(int postId) async {
    try {
      LoadingOverlay.show(context);
      List<dynamic> result =
          await _adviceModel.getAdvisersData(context, postId);
      print("result: $result");
      setState(() {
        _advicers = result;
        _isLoading = false;
      });
    } catch (e) {
      print("!!!!!!!!!!!!!!!!!!advicers 중 에러 발생 : $e");
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
    _loadAdvisersData(_postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('첨삭자 목록'),
      ),
      body: ListView.separated(
        itemCount: _advicers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: _advicers[index]['profilePic'] != null
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserpageScreen(userId: _advicers[index]['id'])),
                      );
                    },
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _advicers[index]['profilePic'],
                        placeholder: (context, url) => SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error_outline,
                          size: 28,
                        ),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserpageScreen(userId: _advicers[index]['id'])),
                      );
                    },
                    child: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/default_profile_image.png')
                                as ImageProvider),
                  ),
            title: Text(
              _advicers[index]['nickname'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // 첨삭자 상세 페이지로 이동
              print('${_advicers[index]['id']} tapped');
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Colors.grey,
        ),
      ),
    );
  }
}
