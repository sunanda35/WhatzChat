import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:whatzzchat/widget/appMethod.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Profileview extends StatefulWidget {
  Profileview({this.usrid});
  final usrid;
  @override
  _ProfileviewState createState() => _ProfileviewState();
}

bool progress = false;
class _ProfileviewState extends State<Profileview> {
  final firestore = Firestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  String user;
  String photo;
  String username;
  String status;
  String phone;
  String state;
  File image;
  var PrePurl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user = widget.usrid;
    });
    firestore.collection('users').document(widget.usrid).snapshots().listen((snap) {
      setState(() {
        PrePurl = snap.data['profile'];
        print(snap.data['profile'].toString());
      });
    });
  }

  proImage(@required ImageSource source) async {
    File selectedImage = await Profile.proimage(source: source, uid: user);
    if(selectedImage==null){
      setState(() {
        progress = false;
      });
    }else{
      setState(() {
        progress = true;
      });
    }
    String purl = await uploadProImage(selectedImage, user);
    setState(() {
      progress = false;
      purl == null
          ? Fluttertoast.showToast(
              msg: "Image not Uploaded due to Internet Issue",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black45,
              textColor: Colors.white,
              fontSize: 16.0)
          : null;
    });
    if(purl!=null){
      await firestore.collection('users').document(user).updateData({
        'profile': purl,
      }).then((_){
        Fluttertoast.showToast(
            msg: "Profile Picture Updated",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            fontSize: 16.0);
      }).catchError((err){
        Fluttertoast.showToast(
            msg: err.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
    setState(() {
      image = selectedImage;
      photo = purl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Whatzz App'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(user)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.data != null) {
                return Container(
                  color: Colors.white70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Container(
                                            height: 70,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    proImage(ImageSource.gallery);
                                                      setState(() {
                                                        progress=false;
                                                      });
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.image,
                                                        size: 50,
                                                        color:
                                                            Colors.deepOrange,
                                                      ),
                                                      Text('Gallery'),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    proImage(
                                                        ImageSource.camera);
                                                    setState(() {
                                                      progress=false;
                                                    });
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.camera_alt,
                                                        size: 50,
                                                        color: Colors.green,
                                                      ),
                                                      Text('Camera'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: CircleAvatar(
                                  radius: 100,
                                  backgroundColor: Colors.lightBlue,
                                  backgroundImage: snapshot.data['profile'] !=
                                          null
                                      ? NetworkImage(snapshot.data['profile'])
                                      : snapshot.data['sex'] == 'm'
                                          ? AssetImage('images/mprofile.webp')
                                          : AssetImage(
                                              'images/fprofile.webp'),
                                  child: Align(
                                    alignment: Alignment(0.9, 0.8),
                                    child: Material(
                                      color: Colors.transparent,
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              color: Colors.white, width: 4)),
                                      child: Icon(
                                        Icons.add_circle,
                                        size: 40,
                                        color: Colors.deepOrangeAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, right: 60.0, top: 20.0),
                        child: TextField(
                          onChanged: (value) {
                            username = value;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.perm_identity),
                            hintText: snapshot.data['username'],
                            labelText: 'Username',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, right: 60.0, top: 20.0),
                        child: TextField(
                          onChanged: (value) {
                            status = value;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.perm_identity),
                            hintText: snapshot.data['status'],
                            labelText: 'Status',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            height: 30,
                            minWidth: 40,
                            color: Colors.blue,
                            child: Text(
                              '< Back',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              setState(() {
                                progress = true;
                              });
                              await firestore
                                  .collection('users')
                                  .document(user)
                                  .updateData({
                                'username': username,
                                'status': status,
                              });
                              setState(() {
                                progress = false;
                              });
                              Navigator.pop(context);
                            },
                            height: 30,
                            minWidth: 40,
                            color: Colors.blue,
                            child: Text(
                              'Update >',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  color: Colors.white70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.lightBlue,
                              backgroundImage: AssetImage('images/profile.jpg'),
                              child: Align(
                                alignment: Alignment(0.7, 0.8),
                                child: Material(
                                  color: Colors.transparent,
                                  shape: CircleBorder(
                                      side: BorderSide(
                                          color: Colors.white, width: 4)),
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 40,
                                    color: Colors.deepOrangeAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, right: 60.0, top: 20.0),
                        child: TextField(
                          onChanged: (value) {
                            username = value;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.perm_identity),
                            hintText: 'Sunanda',
                            labelText: 'Username',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, right: 60.0, top: 20.0),
                        child: TextField(
                          onChanged: (value) {
                            status = value;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.perm_identity),
                            hintText: 'hyy, i love you',
                            labelText: 'Status',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            height: 30,
                            minWidth: 40,
                            color: Colors.blue,
                            child: Text(
                              '< Back',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              setState(() {
                                progress = true;
                              });
                              await firestore
                                  .collection('users')
                                  .document(user)
                                  .updateData({
                                'username': username,
                                'status': status,
                              });
                              setState(() {
                                progress = false;
                              });
                            },
                            height: 30,
                            minWidth: 40,
                            color: Colors.blue,
                            child: Text(
                              'Update >',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
