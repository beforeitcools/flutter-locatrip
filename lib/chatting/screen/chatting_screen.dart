import 'package:flutter/material.dart';
import 'package:flutter_locatrip/chatting/model/chat_model.dart';
import 'package:flutter_locatrip/chatting/ui/chat_list_ui.dart';
import 'package:flutter_locatrip/common/widget/color.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final ChatModel _chatModel = ChatModel();
  List<dynamic> _chats = [];
  dynamic _selectedChat;

  bool _showTextfield = false;
  String _searchButtonText = "";
  TextEditingController _controller = TextEditingController();

  void _loadChatData() async
  {
    List<dynamic> chatData = await _chatModel.fetchMessageData(1);
    setState(() {
      _chats = chatData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChatData();
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
              child: Icon(Icons.search, color: grayColor)
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
                return ChatListUi(chatroomId: chat["chatroomId"], sender: chat["userId"].toString(), currentMessage: chat["messageContents"]);
              })
    );
  }
}

class searchPage extends StatefulWidget {
  const searchPage({super.key});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "검색어를 입력하세용",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16), // Add some spacing
            const Text("히힛"),
          ],
        ),
      ),
    );

  }
}
