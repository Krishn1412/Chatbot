import 'dart:html';

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'model/chatModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Dialog Flowtter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _inputMessageController = TextEditingController();

  List<ChatMessage> messages = [];
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
        children: [
          const Center(
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/masti.png'),
              backgroundColor: Colors.transparent,
              radius: 40.0,
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
              // this listview displays all the messages
              itemCount: messages.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print('${messages[index].messageContent} pressed');
                    if (messages[index].messageCategory == "suggestion") {
                      fetchFromDialogFlow(messages[index].messageContent);
                    }
                    if (messages[index].messageCategory == "activity") {
                      // redirect to pap activity
                      print('redirected to pap');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (messages[index].messageType == "receiver"
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (messages[index].messageType == "receiver"
                              ? Colors.grey.shade200
                              : (messages[index].messageCategory == "suggestion"
                                  ? const Color.fromARGB(225, 143, 164, 245)
                                  : (messages[index].messageCategory ==
                                          "activity"
                                      ? const Color.fromARGB(225, 171, 74, 45)
                                      : const Color.fromRGBO(
                                          227, 207, 201, 30)))),

                          //   image: DecorationImage(
                          //     fit: BoxFit.fill,
                          //     image: (messages[index].messageCategory  == "activity"? AssetImage('assets/bubbles.jpg'):AssetImage('assets/pq.png'))
                          // ),
                        ),
                        padding: (messages[index].messageCategory == "activity"
                            ? const EdgeInsets.fromLTRB(28, 19, 28, 19)
                            : const EdgeInsets.all(16)),
                        child: Text(
                          messages[index].messageContent,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
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
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }




/////////////FUNCTIONS//////////////////////
// initializing dialogflow

  _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
  initiateDialogFlow() async {
    DialogAuthCredentials credentials = await DialogAuthCredentials.fromFile("assets/chatbotkey.json");
    dialogFlowtter = DialogFlowtter(credentials: credentials,);
     messages.add(ChatMessage(
        messageContent:"Hello I am MASTHI, and I am here to help!! How are you feeling today?? ",
        messageType: "receiver",
        messageCategory: "reply"));
    var suggestions = ["Sad", "Tired", "Worried", "Angry", "Sleep"];
    for (var suggestion in suggestions) {
      messages.add(ChatMessage(
          messageContent: suggestion,
          messageType: "sender",
          messageCategory: "suggestion"));
    }
    setState(() {});
  }
// send message and detect intent
  fetchFromDialogFlow(String text) async {
    if (text.isEmpty) return;
    setState(() {
          messages.add(ChatMessage(
          messageContent: text,
          messageType: "sender",
          messageCategory: "sent"));
    });
    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );
    Map data =response.toJson()["queryResult"]["fulfillmentMessages"][0]["payload"];
    // print(data);
    messages.add(ChatMessage(
        messageContent: data['reply'],
        messageType: "receiver",
        messageCategory: "reply"));
    for (var suggestion in data['suggestions']) {
      messages.add(ChatMessage(
          messageContent: suggestion,
          messageType: "sender",
          messageCategory: "suggestion"));
    }
    for (var activity in data['activity']) {
      messages.add(ChatMessage(
          messageContent: activity,
          messageType: "sender",
          messageCategory: "activity"));
    }
    setState(() {});
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }
  
}
