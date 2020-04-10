import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:whatzzchat/chat/Gchatting.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChat extends StatefulWidget {
  @override
  _GroupChatState createState() => _GroupChatState();
}

String userid;
String phon;
String name;
String pic;

class _GroupChatState extends State<GroupChat> {
  final auth = FirebaseAuth.instance;
  final Future<FirebaseUser> loginuser = FirebaseAuth.instance.currentUser();
  String photo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance.collection('group').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.documents[index].documentID != userid) {
                      return GroupFace(snapshot.data.documents[index], context);
                    } else {
                      return Container();
                    }
                    //Text(snapshot.data.documents[index].data['username'].toString());
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

Widget GroupFace(DocumentSnapshot snapshot, context) {
  return Padding(
    padding: const EdgeInsets.only(top: 9, left: 10, right: 10),
    child: GestureDetector(
      onTap: () {
        print(DateTime.now());
        Navigator.push(context, MaterialPageRoute(builder: (context)=>gChatting(
          recivID: snapshot.documentID,
        )));
//                Scaffold.of(context).showSnackBar(SnackBar(
//                    content: Text('Tap'),));
      },
      child: Column(
        children: <Widget>[
          Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  snapshot['photo'] == null
                      ? CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    AssetImage('images/mprofile.webp'),
                  )
                      : CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    NetworkImage(snapshot['photo']),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * .57,
                          child: Text(
                            snapshot['gname'],
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .57,
                        child: Text(
                          snapshot['tag'],
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, left: 56),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.2),
                  ),
                ),
                height: 3,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

