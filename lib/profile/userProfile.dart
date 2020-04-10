import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatzzchat/call/pickup/pickup_layout.dart';

class userProfile extends StatefulWidget {
  userProfile({this.useid});
  final useid;
  @override
  _userProfileState createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  String recID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      recID = widget.useid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text('Whatzz Chat'),
        ),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(recID)
                .snapshots(),
            builder: (context,  AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.data != null) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) => GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: AlertDialog(
                                            contentPadding: EdgeInsets.all(0),
                                            elevation: 100,
                                            backgroundColor: Colors.blueGrey,
                                            content: snapshot.data['profile']!=null? Image.network(
                                              snapshot.data['profile'],
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent
                                                          loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ):Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage('images/loading.gif'),
                                                    fit: BoxFit.fitWidth,
                                                  )
                                              ),
                                              child: Text('Image not available'),
                                            ),),
                                      ));
                            },
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.black26,
                              backgroundImage: snapshot.data['profile']!=null?NetworkImage(snapshot.data['profile']):snapshot.data['sex']=='m'?AssetImage('mprofile.webp'):AssetImage('fprofile.webp'),
                              child: snapshot.data['state'] == 'on'
                                  ?  Align(
                                alignment: Alignment(0.9, 0.8),
                                child: Material(
                                  color: Colors.transparent,
                                  shape: CircleBorder(
                                      side: BorderSide(
                                          color: Colors.white, width: 4)),
                                  child: Icon(Icons.radio_button_checked,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                              ):Container(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.chat,
                              size: 30,
                              color: Colors.indigo,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.videocam,
                              size: 32,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Name: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black26),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              snapshot.data['username'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Number: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black26),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              snapshot.data['phone'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Container(color: Colors.deepOrange),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Status: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black26),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              snapshot.data['status'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return CircularProgressIndicator(
                  strokeWidth: 4,
                );
              }
            }),
      ),
    );
  }
}
