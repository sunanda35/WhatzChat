import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'package:whatzzchat/chat/chatting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatzzchat/profile/profileviewer.dart';
import 'package:whatzzchat/widget/appMethod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatzzchat/constant.dart';

class Pchat extends StatefulWidget {
  @override
  _PchatState createState() => _PchatState();
}

String userid;
String phone;
String name;
String pic;

class _PchatState extends State<Pchat> {
  final auth = FirebaseAuth.instance;
  final Future<FirebaseUser> loginuser = FirebaseAuth.instance.currentUser();
  String photo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth.currentUser().then((loginuser) {
      setState(() {
        userid = loginuser.uid;
        uId = loginuser.uid;
        phone = loginuser.phoneNumber;
        firestore.collection('users').document(loginuser.uid).updateData({
          'state': 'on',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context,  snapshot) {
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
                    if (snapshot.data.documents[index].documentID != uId ) {
                      return ChatFace(snapshot.data.documents[index], context);
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

Widget ChatFace(DocumentSnapshot snapshot, context) {
  String getTime(String kalu) {
    var time, stamp;
    List<String> month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    var nstring = DateTime.now().toIso8601String().substring(0, 17);
    int k = int.parse(kalu.substring(11, 13));
    if (k >= 12) {
      time = k - 12;
      if (k == 12) {
        stamp = 'PM';
        time = 12;
      }
      stamp = 'PM';
    } else {
      time = k;
      stamp = 'AM';
    }

    if (kalu.substring(0, 10) == nstring.substring(0, 10)) {
      if (int.parse(kalu.substring(11, 13)) ==
              int.parse(nstring.substring(11, 13))) {
        return (int.parse(nstring.substring(14,16))-int.parse(kalu.substring(14,16)))
            .toString() +
            'm ago';

      }else if(int.parse(kalu.substring(11, 13)) + 1 ==
          int.parse(nstring.substring(11, 13))){
        if (((60-int.parse(kalu.substring(14,16)))+(60-(60-int.parse(nstring.substring(14,16)))))<60) {
          return ((60-int.parse(kalu.substring(14,16)))+(60-(60-int.parse(nstring.substring(14,16)))))
              .toString() +
              'm ago';
        }

      }
      return time.toString() + kalu.substring(13, 16) + " " + stamp;
    } else {
      return kalu.substring(8, 10) +
          ' ' +
          month[int.parse(kalu.substring(5, 7)) - 1] +
          ', ' +
          kalu.substring(2, 4);
    }
  }

  return Padding(
    padding: const EdgeInsets.only(top: 9, left: 10, right: 10),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chatting(
                    recivID: snapshot.documentID,
                    userid: userid,
                  )),
        );
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
                  snapshot['profile'] == null
                      ? snapshot['sex'] == 'm'
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage('images/mprofile.webp'),
                              child: snapshot['state'] != "on"
                                  ? Container()
                                  : Align(
                                      alignment: Alignment.bottomRight,
                                      child: Material(
                                        color: Colors.transparent,
                                        shape: CircleBorder(
                                            side: BorderSide(
                                                color: Colors.white, width: 4)),
                                        child: snapshot['state'] != "on"
                                            ? Container()
                                            : Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors.white,
                                                          width: 4)),
                                                  child: Icon(
                                                    Icons.lens,
                                                    color:
                                                        Colors.lightBlueAccent,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage('images/fprofile.webp'),
                              child: snapshot['state'] != "on"
                                  ? Container()
                                  : Align(
                                      alignment: Alignment.bottomRight,
                                      child: Material(
                                        color: Colors.transparent,
                                        shape: CircleBorder(
                                            side: BorderSide(
                                                color: Colors.white, width: 4)),
                                        child: snapshot['state'] != "on"
                                            ? Container()
                                            : Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors.white,
                                                          width: 4)),
                                                  child: Icon(
                                                    Icons.lens,
                                                    color:
                                                        Colors.lightBlueAccent,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                            )
                      : CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.black26,
                          backgroundImage: NetworkImage(snapshot['profile']),
                          child: snapshot['state'] != "on"
                              ? Container()
                              : Align(
                                  alignment: Alignment.bottomRight,
                                  child: Material(
                                    color: Colors.transparent,
                                    shape: CircleBorder(
                                        side: BorderSide(
                                            color: Colors.white, width: 4)),
                                    child: Icon(
                                      Icons.lens,
                                      color: Colors.lightBlueAccent,
                                    ),
                                  ),
                                ),
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
                            snapshot['username'],
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
                          snapshot['status'] == null
                              ? 'Status not available'
                              : snapshot['status'],
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  snapshot.data['state'] == 'on'
                      ? Container(
                          height: 20,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.lightBlueAccent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Online',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : Text(getTime(snapshot.data['state'].toString())),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    height: 20,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30.0)),
                    alignment: Alignment.center,
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

class DrawerOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(userid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data == null) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                  image: DecorationImage(
                    image: AssetImage('images/mprofile.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 49,
                    width: MediaQuery.of(context).size.width * 0.60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    ),
                  ),
                ),
              );
            } else {
              phone = snapshot.data['phone'];
              return GestureDetector(
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
                              content: snapshot.data['profile'] != null
                                  ? Image.network(
                                      snapshot.data['profile'],
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
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
                                    )
                                  : Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: AssetImage('images/loading.gif'),
                                        fit: BoxFit.fitWidth,
                                      )),
                                      child: Text('Image not available'),
                                    ),
                            ),
                          ));
                },
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    image: DecorationImage(
                      image: snapshot.data['profile'] == null
                          ? snapshot.data['sex'] == 'm'
                              ? AssetImage('images/mprofile.webp')
                              : AssetImage('images/fprofile.webp')
                          : NetworkImage(snapshot.data['profile']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      //drawer close
                      Navigator.pop(context);
                      //Goes to profile editor widget
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profileview(
                                    usrid: userid,
                                  )));
                    },
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        height: 49,
                        width: MediaQuery.of(context).size.width * 0.60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black54,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        snapshot.data['username'],
                                        style: TextStyle(
                                          color: Colors.deepOrangeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      snapshot.data['phone'],
                                      style: TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_drop_down_circle,
                                color: Colors.lightBlueAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
        ListTile(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.feedback,
                color: Colors.black54,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Feedback',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            var feedback;
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                content: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.feedback,
                        color: Colors.deepOrange,
                        size: 60,
                      ),
                      TextField(
                        onChanged: (value) {
                          feedback = value;
                        },
                        decoration: InputDecoration(
                            labelText: 'Give Your Valuable Feedback'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          firestore.collection('feedback').add({
                            "uid": userid,
                            'phone': phone,
                            'feedback': feedback,
                          });
                        },
                        splashColor: Colors.deepOrange,
                        hoverElevation: 6,
                        color: Colors.blueAccent,
                        focusColor: Colors.deepOrange,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Done',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Icon(
                              Icons.done,
                              color: Colors.orangeAccent,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ListTile(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.share,
                color: Colors.black54,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Invite friends',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          onTap: () {
            final RenderBox box = context.findRenderObject();
            Share.share('Check out WhatzzApp, I use it to message and call the people i care about them. Get it for free on https://whatzz_chat.com',
                subject: 'Invite Friends',
                sharePositionOrigin:
                box.localToGlobal(Offset.zero) &
                box.size);
          },
        ),
        ListTile(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.info,
                color: Colors.black54,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Terms and Policy',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                content: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                            'No terms and condition apply in this app, you are free to use as you like,'),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Remember it, Any data except account data, can be deleted at any time due to small storage capacity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        ListTile(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.exit_to_app,
                color: Colors.black54,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Log Out',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          onTap: ()async {
            addOnExitListener(userid: userid);
            SharedPreferences login = await SharedPreferences.getInstance();
            login.setBool('loginData', false);
            Fluttertoast.showToast(
                msg: 'Logged out',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black45,
                textColor: Colors.white,
                fontSize: 16.0);
              Navigator.of(context).pushNamed('auth');
          },
        ),
        SizedBox(
          height: 100,
        ),
        ListTile(
            title: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('from'),
              SizedBox(
                height: 6,
              ),
              GestureDetector(
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => AlertDialog(
                              content: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            _launchUniversalLinkIos(
                                                'https://www.linkedin.com/in/sunanda35');
                                          },
                                          child: Text(
                                            'LinkdIN',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 19,
                                      ),
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            _launchUniversalLinkIos(
                                                'https://github.com/sunanda35');
                                          },
                                          child: Text(
                                            'GitHub',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                  },
                  child: Text(
                    'SUNANDA SAMANTA',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.tealAccent),
                  )),
            ],
          ),
        )),
      ],
    );
  }
}

Future<void> _launchUniversalLinkIos(String url) async {
  if (await canLaunch(url)) {
    final bool nativeAppLaunchSucceeded = await launch(
      url,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
    if (!nativeAppLaunchSucceeded) {
      await launch(
        url,
        forceSafariVC: true,
      );
    }
  }
}
