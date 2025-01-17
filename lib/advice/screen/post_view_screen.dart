import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/model/post_model.dart';
import 'package:flutter_locatrip/advice/widget/trip_for_advice.dart';
import 'package:flutter_locatrip/common/model/json_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostViewScreen extends StatefulWidget {
  // post id는 query parameter로 가지고 있을 거기 때문에 만약에 필요한 애들이 있으면은 거기서 가져와주면 되긔 ...
  // 포스트 타이틀이랑 포스트는 어케 가져와염 그냥 포스트 번호를 넘겨받어?


  final int postId;
  PostViewScreen({super.key, required this.postId});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {

 String _tripData = "";

  final PostModel _postModel = PostModel();
  final JsonParser _jsonParser = JsonParser();
  
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late final int myUserId;
  dynamic _postData = [];

  Future<void> _getUserId() async{
    final dynamic stringId = await _storage.read(key: 'userId');
    myUserId = int.tryParse(stringId) ?? 0; // 현재 유저 아이디
  }

  void _initPostData(int postId) async{
    //query parameter로 넘겨주는 postID
    _postData = await _postModel.getPostById(postId, context);
    print('$_postData 여행 넘겨 받았어?!?!?!');
    _updateValue(_postData["advicedTripData"]);

  }

  void _updateValue(String value){
    setState(() {
      _tripData = value;
    });
  }


  @override
  void initState() {
    super.initState();
    _getUserId();
    _initPostData(widget.postId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){Navigator.pop(context);Navigator.pop(context);}, icon: Icon(Icons.arrow_back_outlined)),
          actions: [
            // TextButton(onPressed: (){/**/}, child: child) 현재 글이 내가 쓴 글인지 검사해서 삭제버튼을 보여줘야함
          ],
        ),
        body: Padding(padding: EdgeInsets.all(16),
            child: _postData == null ? Center(child: CircularProgressIndicator())
                : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(_postData["title"], style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  Text(_postData["contents"], style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: (){}, child: Text("채택하러 가기")),
                  SizedBox(height: 16),
                  Text("전체첨삭"),
                  _tripData.isEmpty ? Center(child: CircularProgressIndicator())
                      : TripForAdvice(tripData: _tripData)
                ])
        )
    );
  }
}
