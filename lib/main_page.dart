import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:send_bird_chat/keys.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'messenger.dart';
import 'package:intl/intl.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          color: Colors.black
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(background: Colors.black),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool haveText = false;

  final messenger = Messenger('5fbb8f12dc0df3ccD9D2');

  final String appId = "BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF";
  String userId = '5fbb8f12dc0df3ccD9D2';
  String channelUrl = 'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211';
  User? user;
  OpenChannel? openChannel;
  late PreviousMessageListQuery query;
  String title = '';
  List<BaseMessage> messageList = [];

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    setState(() {
      isLoading = true;
    });
    await messenger.initialize();

    SendbirdChat.addChannelHandler('OpenChannel', MyOpenChannelHandler(this));
    SendbirdChat.addConnectionHandler('OpenChannel', MyConnectionHandler(this));

    OpenChannel.getChannel(channelUrl).then((openChannel) {
      this.openChannel = openChannel;
      openChannel.enter().then((_) => OpenChannel.getChannel(channelUrl).then((openChannel) {
        query = PreviousMessageListQuery(
          channelType: ChannelType.open,
          channelUrl: channelUrl,
        )..next().then((messages) {
          setState(() {
            messageList
              ..clear()
              ..addAll(messages);
            title = '${openChannel.name} (${messageList.length})';
            Future.delayed(Duration(milliseconds: 50),() {
                      setState(() {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                        );
                      });
                    });

            isLoading = false;
          });
        });
      }));
    });
  }

  void _addMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        messageList.add(message);
        title = '${openChannel.name} (${messageList.length})';

        Future.delayed(Duration(milliseconds: 200),() {
          setState(() {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
          });
        });
      });

    });
  }


  void _sendMessage() async {
    try {
      if (_textController.value.text.isEmpty) {
        return;
      }

      openChannel?.sendUserMessage(
        UserMessageCreateParams(
          message: _textController.value.text,
        ),
        handler: (UserMessage message, SendbirdException? e) async {
          if (e != null) {
            // await _showDialogToResendUserMessage(message);
          } else {
            _addMessage(message);
          }
        },
      );

      _textController.clear();

    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Widget _buildMessageList() {
    return Flexible(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(8.0),
        itemCount: messageList.length,
        itemBuilder: (_, int index) {

          return (messageList[index].sender?.userId == userId) ? _buildSentMessage(messageList[index]) :_buildReceivedMessage(messageList[index]);
        }
      ),
    );
  }

  Widget _buildReceivedMessage(BaseMessage message) {
    String receivedTime = DateFormat('h:mm a', 'ko_KR').format(DateTime.fromMillisecondsSinceEpoch(message.createdAt));
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
        children: [

          CircleAvatar(
            radius: 20, // Set the radius as needed
            backgroundImage: NetworkImage(
                (message.sender?.profileUrl != null &&  message.sender!.profileUrl.isNotEmpty)
                    ? message.sender!.profileUrl
                    : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width / 2 + 80
                  ),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight:  Radius.circular(4),
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(16)
                      ),
                      color: Color(0xff1A1A1A)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(message.sender?.nickname.isNotEmpty != null ? message.sender!.nickname : message.sender!.userId.substring(1,8), style: const TextStyle(color: Color(0xffADADAD), fontSize: 14)),

                      Text(message.message, style: TextStyle(color: Colors.white, fontSize: 16),),
                    ],
                  )),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
    // "1분 전"
                  Text(receivedTime, style: const TextStyle(color: Color(0xff9C9CA3), fontSize: 8)),
                ],
              ),
            ],
          )

        ],
      );
  }

  Widget _buildSentMessage(BaseMessage message) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.fromLTRB(10,10,10,12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width / 2 + 80
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight:  Radius.circular(4),
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(18)
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffFF006B), Color(0xffFF4593)],
              ),
            ),
              child: Text(message.message, style: const TextStyle(color: Colors.white),maxLines: 1000)
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {

    return Container(
      margin: EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(onPressed: () {},
              icon: Icon(Icons.add, color: Colors.white,)),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: Keys.borderColor),
                  borderRadius: BorderRadius.all(Radius.circular(30))
              ),
              child: Row(
                children: [
                  SizedBox(width: 20,),
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: Colors.white, fontFamily: "Pretendard"),
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '메세지 보내기',
                        hintStyle: TextStyle(color: Keys.borderColor),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          haveText = value.isNotEmpty;
                        });
                      },
                        onEditingComplete: () => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.arrow_up_circle_fill,
                      size: 34,
                      color: haveText ? Keys.primaryColor : Keys.borderColor,//#FF006A
                    ),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {

          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {

            },
          ),
        ],
      ),
      body: Column(
        children: [
          isLoading ? const Expanded(child: Center(child: CircularProgressIndicator(color: Keys.primaryColor,))) :
          _buildMessageList(),
          _buildTextField()
        ],
      ),
    );
  }
  @override
  void dispose() {
    SendbirdChat.removeChannelHandler('OpenChannel');
    SendbirdChat.removeConnectionHandler('OpenChannel');
    _textController.dispose();

    OpenChannel.getChannel(channelUrl).then((channel) => channel.exit());
    super.dispose();
  }
}

class MyOpenChannelHandler extends OpenChannelHandler {
  final _MyHomePageState _state;

  MyOpenChannelHandler(this._state);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    _state._addMessage(message);
  }

}

class MyConnectionHandler extends ConnectionHandler {
  final _MyHomePageState _state;

  MyConnectionHandler(this._state);

  @override
  void onConnected(String userId) {}

  @override
  void onDisconnected(String userId) {}

  @override
  void onReconnectStarted() {}

  @override
  void onReconnectSucceeded() {
    _state.initialize();
  }

  @override
  void onReconnectFailed() {}
}

