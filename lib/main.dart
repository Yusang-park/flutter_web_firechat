import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    // TODO: implement initState
    initializeFlutterFire();
    super.initState();
  }

  //파이어베이스 초기화 함수
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        //    loadFirebase();
      });
    } catch (e) {
      // Set `_error` stat7e to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'firechat', home: ChatScreen());
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<QueryDocumentSnapshot> doclist = [];

  TextEditingController sendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('firechat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: messageLine(),
            ),
            Divider(
              thickness: 1,
            ),
            bottomInputLine(width, height)
          ],
        ));
  }

  Widget bottomInputLine(width, height) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Colors.black12),
        height: 40,
        width: width * 1,
        margin:
            EdgeInsets.only(left: width * 0.03, right: width * 0.03, bottom: 7),
        padding: EdgeInsets.only(left: width * 0.015, right: width * 0.015),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 9,
              child: TextField(
                controller: sendController,
                textAlign: TextAlign.left,
                decoration: InputDecoration.collapsed(hintText: '대화를 입력하세요.'),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  _sendMessage(sendController.text, '유상');
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              color: Colors.blue,
              onPressed: () {},
            )
          ],
        ));
  }

  Widget messageLine() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chat').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('채팅이 없습니다.'),
          );
        }
        doclist = snapshot.data.docs; //list<docs>
        return ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _buildReciveMessage(doclist[doclist.length - 1 - index]);
          },
          itemCount: doclist.length,
        );
      },
    );
  }

  Widget _buildReciveMessage(doc) {
    return Container(
      child: Text(doc.data()['name'] + ' ' + doc.data()['message']),
    );
  }

  void _sendMessage(message, userid) {
    FirebaseFirestore.instance
        .collection('chat')
        .add({'name': userid, 'message': message});
    sendController.clear();
  }
}
