import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatefulWidget {
  static String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  //This is used to control the TextField (the chat textfield), and it should be used in a controlled property (controller: messagetextController),
  //and inside the onPressed we use messagetextController.clear();
  TextEditingController messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late String messageText;
  final _firestore = FirebaseFirestore.instance;



  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser!;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }catch (e){
      print(e);
    }
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()){
      for (var message in snapshot.docs){
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //Streams make messaging live, it updates like a lighting strike (fast).
            StreamBuilder(
              stream: _firestore.collection("messages").orderBy("timeStamp").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  var messages = snapshot.data?.docs.reversed;
                  List<Widget> messageBubbles = [];
                  for (var message in messages!) {
                    final messageText = message["text"];
                    final messageSender = message["sender"];
                    final currentUser = loggedInUser.email;
                    final messagebubble = MessageBubble(
                        text: messageText,
                        sender: messageSender,
                        isMe: currentUser == messageSender,

                    );
                    messageBubbles.add(messagebubble);

                  }
                  return Expanded(
                    child: ListView(
                      //This code makes the screen to show the last message sent.
                      //But we also need to put (.reversed) on the messages.snapshot.
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      children: messageBubbles,
                    ),
                  );

              },
            ),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection("messages").add({
                        "text": messageText,
                        "sender": loggedInUser.email,
                        //This timeStamp is needed for showing the recent messages on the sreen
                        "timeStamp": FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({required this.text, required this.sender, required this.isMe});
  late String text;
  late String sender = sender.split('@')[0];
  late bool isMe;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender.split('@')[0], style: TextStyle(
            color: Colors.black54,
            fontSize: 12.0,
          ),),

          Material(
            elevation: 5.0,
            borderRadius: isMe? meBubbleDecoration : themBubbleDecoration,
            color: isMe? Colors.lightBlueAccent : Colors.white70,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 15.0,
                        color: isMe? Colors.white : Colors.black,
                ),),
            ),
          ),
        ],
      ),
    );
  }
}
