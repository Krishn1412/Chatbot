import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'model/chatModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Chatbot(),
    );
  }
}
class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  List<ChatMessage> messages = [];
  final TextEditingController _inputMessageController = TextEditingController();
  late Dialogflow dialogflow;
  late AuthGoogle authGoogle;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await initiateDialogFlow();
    });
  }

  @override
  Widget build(BuildContext context) {
    _scrollToBottom();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 239, 238, 10),
      body: Stack(
          children:[
            const Center(
              child:CircleAvatar(
                backgroundImage: AssetImage('assets/masti.png'),
                backgroundColor: Colors.transparent,
                radius:40.0,
              ),
            ),
            const SizedBox(height: 40.0),
            Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            chatSpaceWidget(),
            Container(
              height: 1.0,
              width: double.infinity,
              color: Colors.blueGrey,
            ),
            bottomChatView()
          ],
        ),
      ],
    ),
    );
  }

  Widget chatSpaceWidget() {
    return Flexible(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ListView.builder(
              itemCount: messages.length,
              shrinkWrap:true,
              padding: const EdgeInsets.only(top: 10,bottom: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return Container(
                  padding: const EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                  child: Align(
                    alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:const Color.fromRGBO(227, 207, 201, 30)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(messages[index].messageContent, style: const TextStyle(fontSize: 15),),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

 Widget bottomChatView() {
    return Container(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
      height: 60,
      width: double.infinity,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: TextField(
              controller: _inputMessageController,
              onSubmitted: (String str) {
                fetchFromDialogFlow(str);
              },
              decoration: const InputDecoration(
                  hintText: "Write message...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          FloatingActionButton(
            onPressed: () {
              fetchFromDialogFlow(_inputMessageController.text);
            },
            backgroundColor: Colors.brown,
            elevation: 0,
            child: const Icon(Icons.send, color: Colors.white,size: 18,),
          ),
        ],
      ),
    );
  }


  // functions

  _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  initiateDialogFlow() async {
    AuthGoogle authGoogle =
    await AuthGoogle(fileJson: 'assets/chatbotkey.json').build();
    dialogflow = Dialogflow(authGoogle: authGoogle, language: Language.english);
    fetchFromDialogFlow("hi");
  }

  fetchFromDialogFlow(String input) async {
    _inputMessageController.clear();
    setState(() {
      messages.add(ChatMessage(messageContent: input, messageType: "sender"));
    });
    AIResponse response = await dialogflow.detectIntent(input);
    // print(response.getListMessage()[0]);
    Map data =(response.getListMessage()[0]);
    print(data['payload']['reply']);
    messages.add(ChatMessage(messageContent: data['payload']['reply'], messageType: "receiver"));
    for(var suggestion in data['payload']['suggestions'])
   { messages.add(ChatMessage(messageContent: suggestion, messageType: "sender"));}
    setState(() {});
  }
}


