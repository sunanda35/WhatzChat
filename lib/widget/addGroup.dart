import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:whatzzchat/chat/public.dart';
import '../constant.dart';
import 'appMethod.dart';

class Gadd extends StatefulWidget {
  @override
  _GaddState createState() => _GaddState();
}

class _GaddState extends State<Gadd> {
  Firestore firestore = Firestore.instance;
  bool progress = false;
  String gname;
  String tagname;
  String url;
  var gid = Random().nextInt(5000).toString();
  String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  String RandomString(int strlen) {
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      gid = RandomString(20);
    });
  }


  proImage(@required ImageSource source)async{
    File selectedImage = await Profile.proimage(source: source);
    if(selectedImage!=null){
      setState(() {
        progress=true;
      });
    }
    storageReferencetoUpload = FirebaseStorage.instance.ref().child('group/${gid}');
    StorageUploadTask storageUploadTask = await storageReferencetoUpload.putFile(selectedImage);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      this.url = url;
      progress=false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppName),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: SafeArea(
          child: Container(
            color: Colors.white70,
            child: Column(
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
                      backgroundImage: AssetImage('images/profile.jpg'),
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 60.0, right: 60.0, top: 20.0),
                  child: TextField(
                    onChanged: (value) {
                      gname = value;
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.perm_identity),
                      labelText: 'Group name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 60.0, right: 60.0, top: 20.0),
                  child: TextField(
                    onChanged: (value) {
                      tagname = value;
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.perm_identity),
                      labelText: 'Tag line',
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    setState(() {
                      progress = true;
                    });
                    await firestore
                        .collection('group')
                        .document(gid)
                        .setData({
                      'gname' : gname,
                      'tag' : tagname,
                    });
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPublic(index: 1,)));
                    setState(() {
                      progress = false;
                    });
                  },
                  height: 30,
                  minWidth: 40,
                  color: Colors.blue,
                  child: Text(
                    'Add >',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}