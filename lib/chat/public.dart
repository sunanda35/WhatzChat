import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatzzchat/call/pickup/pickup_layout.dart';
import 'package:whatzzchat/chat/group.dart';
import 'package:whatzzchat/profile/authentication.dart';
import 'package:whatzzchat/status/status.dart';
import 'package:whatzzchat/widget/addGroup.dart';
import 'package:whatzzchat/widget/appMethod.dart';
import 'package:whatzzchat/widget/pchat.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constant.dart';

class ChatPublic extends StatefulWidget {
  final int index;
  ChatPublic({this.index});

  @override
  _ChatPublicState createState() => _ChatPublicState();
}

DateTime currentBackPressTime;
String UserID;

class _ChatPublicState extends State<ChatPublic> {
  FirebaseAuth auth = FirebaseAuth.instance;
  int selector = 0;
  List<String> categories = ['Chats', 'Group', 'Status'];
  LoginData() async {
    try{
      SharedPreferences login = await SharedPreferences.getInstance();
      if (login.getBool('loginData') == false || login.getBool('loginData') == null) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>chatapp()));
      }

      print(login.getBool('loginData'));
    }catch(er){print(er.message);}
  }

  @override
  void initState() {
    super.initState();
    LoginData();
    if (widget.index != null) {
      setState(() {
        selector = widget.index;
      });
    }
    auth.currentUser().then((loginuser) {
      setState(() {
        UserID = loginuser.uid;
        uId = loginuser.uid;
        phone = loginuser.phoneNumber;
        firestore.collection('users').document(loginuser.uid).updateData({
          'state': 'on',
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    addOnExitListener();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onWillPop(),
      child: PickupLayout(
        scaffold: Scaffold(
          endDrawer: Drawer(
            //add drawer data
            child: DrawerOption(),
          ),
           floatingActionButton: FloatingActionButton(
            onPressed: (){
              selector == 1? Navigator.push(context, MaterialPageRoute(builder: (context)=>Gadd())):null;
            },
              child: Icon(
                selector==0? Icons.chat: selector==1? Icons.add: Icons.border_color,
                )
          ),
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: (){},
              icon: Icon(
                Icons.camera_alt,
                color: Colors.white60,
              ),
            ),
            title: Text(AppName),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  height: 68.0,
                  color: Colors.blue,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selector = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 20.0),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: index == selector
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
                Expanded(
                  child: selector == 0
                      ? Pchat()
                      : selector == 1 ? GroupChat() : Status(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> onWillPop() {
  DateTime now = DateTime.now();
  Fluttertoast.showToast(
    msg: "Double Tap to EXIT",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    fontSize: 14,
  );
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    addOnExitListener(userid: UserID);
    return Future.value(false);
  }
  exit(0);
  return Future.value(true);
}
