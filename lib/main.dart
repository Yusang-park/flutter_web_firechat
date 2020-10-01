import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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
    return MaterialApp(title: 'firechat', home: JoinScreen());
  }
}

class JoinScreen extends StatefulWidget {
  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  TextEditingController _controller = TextEditingController();
  final scaffoldKey =
      GlobalKey<ScaffoldState>(); //스낵바를 위한 글로벌키, scaffold가 context이면 필요함
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: Padding(
            padding: EdgeInsets.only(top: 30),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '익명 채팅에 오신 것을 환영합니다. \ndev by pitter Park',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 9),
                      width: 300,
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   color: Colors.black12,
                      // ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple)),
                          hintText: '닉네임을 입력하세요',
                          labelText: 'Nickname',
                          labelStyle: TextStyle(color: Colors.deepPurple),
                          prefixIcon: Icon(
                            Icons.perm_identity,
                            color: Colors.deepPurple,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ButtonTheme(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      buttonColor: Colors.deepPurple,
                      child: RaisedButton(
                          onPressed: () {
                            if (_controller.text.isEmpty) {
                              scaffoldKey.currentState.showSnackBar(
                                  SnackBar(content: Text('닉네임을 입력하세요')));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            nickname: _controller.text,
                                          )));
                            }
                          },
                          child: Text(
                            '시작하기',
                            style: TextStyle(color: Colors.white),
                          )),
                    )
                  ],
                ))));
  }
}

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key key,
    this.nickname,
    this.option,
  }) : super(key: key);

  final nickname;
  final option;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<QueryDocumentSnapshot> doclist = [];

  TextEditingController sendController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusnode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  String nowTime() {
    var now = new DateTime.now();
    //now = now.add(new Duration(hours: 9));
    var _hour = now.hour;
    var ampm = '오전';
    if (now.hour > 12) {
      ampm = '오후';
      _hour = _hour - 12;
    }

    return ampm + ' ' + _hour.toString() + ':' + now.minute.toString();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
            title: Text('firechat (' + widget.nickname + '님)'),
            backgroundColor: Colors.deepPurple),
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
                focusNode: _focusnode,
                controller: sendController,
                textAlign: TextAlign.left,
                decoration: InputDecoration.collapsed(hintText: '대화를 입력하세요.'),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value != null)
                    _sendMessage(sendController.text, widget.nickname);
                  _focusnode.requestFocus();
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              color: Colors.blue,
              onPressed: () {
                if (sendController.text.isNotEmpty)
                  _sendMessage(sendController.text, widget.nickname);
              },
            )
          ],
        ));
  }

  Widget messageLine() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            "no",
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('채팅이 없습니다.'),
          );
        }
        doclist = snapshot.data.docs; //list<docs>
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 200));
        }
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (doclist[doclist.length - 1 - index].data()['name'] ==
                widget.nickname) {
              return _buildMyMessage(doclist[doclist.length - 1 - index]);
            } else {
              return _buildReciveMessage(doclist[doclist.length - 1 - index]);
            }
          },
          itemCount: doclist.length,
        );
      },
    );
  }

  Widget _buildReciveMessage(doc) {
    return Container(
        margin: EdgeInsets.only(bottom: 10, left: 15),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    doc.data()['name'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        constraints:
                            BoxConstraints(maxWidth: 250), //max, min, 유동적 크기
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color(0xFFECECEC),
                        ),

                        child: Text(
                          doc.data()['message'],
                          overflow: TextOverflow.clip, //줄넘김
                        ),
                      ),
                      Text(
                        doc.data()['time'], //시간 수정할 것.
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  )
                ],
              )
            ]));
  }

  Widget _buildMyMessage(doc) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Text(
              doc.data()['time'],
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 250), //max, min, 유동적 크기
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Color(0xFF00A192),
            ),
            child: Text(doc.data()['message'],
                overflow: TextOverflow.clip, //줄넘김
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendMessage(message, userid) {
    int len = doclist.length;
    FirebaseFirestore.instance.collection('chat').add(
        {'name': userid, 'message': message, 'no': len + 1, 'time': nowTime()});
    sendController.clear();
  }
}
