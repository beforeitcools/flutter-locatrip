import 'package:flutter/material.dart';
import 'package:flutter_locatrip/advice/screen/post_view_screen.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/ui/chat_list_ui.dart';
import 'package:flutter_locatrip/chatting/widgets/test_editting_page.dart';
import 'package:flutter_locatrip/chatting/widgets/websocket_page.dart';
import 'package:flutter_locatrip/common/widget/color.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final ChatModel _chatModel = ChatModel();
  List<dynamic> _chats = [];

  bool _showTextfield = false;
  String _searchButtonText = "";
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  void _loadChatData() async
  {
    List<dynamic> chatData = await _chatModel.fetchMessageData(context);
    setState(() {
      _chats = chatData;
    });
  }

  void _toggleSearchButton()
  {
    setState(() {
      _showTextfield = !_showTextfield;
      if(!_showTextfield){
        _searchButtonText = _controller.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅", style: Theme.of(context).textTheme.headlineLarge),
        actions: [
          InkWell(
            onTap: (){/*search*/_toggleSearchButton();},
            child: Container(
              padding: EdgeInsets.all(10),
              child: !_showTextfield ? Icon(Icons.search, color: grayColor) : Icon(Icons.close, color: grayColor)
            ),
        )],
      ),
      body: _showTextfield ? searchPage() :
      _chats.isEmpty ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("대화 목록이 아직 없어요", style: Theme.of(context).textTheme.titleMedium),
              Text("여행을 위한 소통을 시작해 보세요!", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: pointBlueColor)),
        ],
      ))
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index){
                final chat = _chats[index];
                return ChatListUi(chatroomId: chat["chatroomId"], chatroomName: chat["chatroomName"], currentMessage: chat["currentMessage"] ?? "");
              }),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context,MaterialPageRoute(builder: (context) => PostViewScreen(postId: 25)));
      }),
    );
  }
}


class searchPage extends StatefulWidget {
  //서치 페이지!!!
  const searchPage({super.key});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  final ChatModel _chatModel = ChatModel();
  List<dynamic> _searchChats = [];  // 검색 결과 담을 리스트
  TextEditingController _searchController = TextEditingController();

  void _searchChatData(String searchKeyword) async
  {
    _searchChats.clear();
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: pointBlueColor,
            content: Text('검색어를 입력해주세요.', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white))),
      );
    }
    else {
        List<dynamic> chatData = await _chatModel.fetchSearchMessageData(searchKeyword, context);
        setState(() {
          _searchChats = chatData;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        // Dismiss keyboard when tapping outside
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [Expanded(
                    child: TextFormField(
                        controller: _searchController,
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                          hintText: "검색어를 입력하세용",
                          hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: grayColor),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                        )),
                  ),
                    IconButton(
                      onPressed: () {
                        // 서치 데이터에 textcontroller.text 넘겨줘야 함
                        _searchChatData(_searchController.text);
                      },
                      icon: const Icon(Icons.search, color: grayColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Add some spacing
                _searchChats.isEmpty ? Center(
                    child: Text("검색 결과가 없습니다.", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: pointBlueColor)))
                    : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchChats.length,
                    itemBuilder: (context, index) {
                      final chat = _searchChats[index];
                      return ChatListUi(chatroomId: chat["chatroomId"],
                          chatroomName: chat["chatroomName"],
                          currentMessage: chat["currentMessage"] ?? "");
                    })
              ],
            ),
          ),
        ));
  }
}
