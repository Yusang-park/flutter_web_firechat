import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String name;

  bool _initialized = false;
  bool _error = false;
  List<DocumentSnapshot> doclist = [];

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
        loadFirebase();
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  loadFirebase() {
    final col = FirebaseFirestore.instance.collection('chat');
    col.get().then((value) {
      Map<int, DocumentSnapshot> map2 = value.docs.asMap();
      doclist = map2.values.toList();
      print(doclist[0].data()['name']);
      print(doclist[1].data()['name']);
      print(doclist.length);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'firechat',
      home: Scaffold(
          appBar: AppBar(
            title: Text('firechat'),
          ),
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: doclist.length,
            itemBuilder: (context, index) {
              return Text(doclist[doclist.length - 1 - index].data()['name'] +
                  doclist[doclist.length - 1 - index].data()['message']);
            },
          )),
    );
  }
}
