import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatzzchat/call/call_screen.dart';
import 'package:whatzzchat/call/pickup/pickup_layout.dart';
import 'package:whatzzchat/profile/authentication.dart';
import 'package:whatzzchat/profile/userProfile.dart';
import 'package:whatzzchat/widget/appMethod.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:whatzzchat/widget/callData.dart';
import 'package:whatzzchat/widget/permision.dart';
import 'package:geolocator/geolocator.dart';

class Chatting extends StatefulWidget {
  Chatting({this.recivID, this.userid});
  final recivID;
  final userid;

  @override
  _ChattingState createState() => _ChattingState();
}

String userid;
String Recieverid;
String Rname; //to take data to location w
class _ChattingState extends State<Chatting> {
  final firestore = Firestore.instance;
  final auth = FirebaseAuth.instance;
  final Future<FirebaseUser> loginuser = FirebaseAuth.instance.currentUser();
  final texteditingcontroller = TextEditingController();
  bool iswritting = false;
  bool emoji = false;
  FocusNode textfield = FocusNode();
  bool picker = false;
  ScrollController listScrollController;
  String mestext;


  Call call = Call();
  String Rpic;
  String Cname;
  String Cpic;
  String UserState;
  bool setter= false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      userid =widget.userid;
      Recieverid = widget.recivID;
    });
    firestore.collection('users').document(userid).snapshots().listen((snap) {
      setState(() {
        Rname = snap.data['username'];
        Rpic = snap.data['profile'];
      });
    });
  }


  void getLocation() async {
    bool location =await Geolocator().isLocationServiceEnabled();
    try {
      setState(() {
        picker = true;
      });
      if(location == false){
        setState(() {
          picker = false;
        });
        Fluttertoast.showToast(
            msg: 'Can\'t get your location, Enable GPS',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (position.latitude != null && position.longitude != null) {
        await firestore
            .collection('messages')
            .document(userid)
            .collection(userid).document(Recieverid).collection(Recieverid)
            .add({
          'senderID': userid,
          'receivID': Recieverid,
          'message': null,
          'long': position.longitude.toString(),
          'latt': position.latitude.toString(),
          'photo': null,
          'read' : 0,
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'location',
//                      'number': loginuser.phoneNumber,
        });
        await firestore
            .collection('messages')
            .document(Recieverid)
            .collection(Recieverid).document(userid).collection(userid)
            .add({
          'senderID': userid,
          'receivID': Recieverid,
          'photo': null,
          'long': position.longitude,
          'latt': position.latitude,
          'message': null,
          'read' : 0,
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'location',
        });
      }
      setState(() {
        picker = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }


  pickFile(File file, String type)async{
    if(file!=null){
      setState(() {
        picker=true;
      });
    }
    try{
      storageReferencetoUpload = FirebaseStorage.instance.ref().child('messages/${type}/${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask = await storageReferencetoUpload.putFile(file);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      print(url);

      await firestore
          .collection('messages')
          .document(userid)
          .collection(userid).document(Recieverid).collection(Recieverid)
          .add({
        'senderID': userid,
        'receivID': Recieverid,
        'message': null,
        'read' : 0,
        'photo': url.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
//                      'number': loginuser.phoneNumber,
      });
      await firestore
          .collection('messages')
          .document(Recieverid)
          .collection(Recieverid).document(userid).collection(userid)
          .add({
        'senderID': userid,
        'receivID': Recieverid,
        'photo': url.toString(),
        'message': null,
        'read' : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
      });
      setState(() {
        picker = false;
      });
    }catch(x){
      setState(() {
        picker = false;
      });
      Fluttertoast.showToast(
          msg: x.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  pickImage(@required ImageSource source) async {
    File selectedImage = await Utils.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        picker = true;
      });
    }
    try {
      await uploadImage(selectedImage, Recieverid, userid);
    } catch (m) {
      setState(() {
        picker = false;
      });
    }
    setState(() {
      picker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    writting(bool data) {
      setState(() {
        iswritting = data;
      });
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          emoji = false;
        });
      },
      child: WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context, ModalRoute.withName('Public'));
        },
        child: PickupLayout(
          scaffold: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('Public'));
                },
                icon: Icon(Icons.arrow_back),
                iconSize: 40,
              ),
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => userProfile(
                        useid: Recieverid,
                      ),
                    ),
                  );
                },
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('users')
                      .document(Recieverid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.data != null) {
                      String getTimeData(String kalu) {
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
                        var nstring =
                            DateTime.now().toIso8601String().substring(0, 17);
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
                          return time.toString() +
                              kalu.substring(13, 16) +
                              " " +
                              stamp;
                        } else {
                          return kalu.substring(8, 10) +
                              ' ' +
                              month[int.parse(kalu.substring(5, 7)) - 1] +
                              ', ' +
                              kalu.substring(0, 4);
                        }
                      }

                      UserState = snapshot.data['state'];
                      Cname = snapshot.data['username'];
                      Cpic = snapshot.data['profile'];
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            snapshot.data['profile'] != null
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    backgroundImage:
                                        NetworkImage(snapshot.data['profile']))
                                : snapshot.data['sex'] == 'm'
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
                                            AssetImage('images/fprofile.webp'),
                                      ),
                            SizedBox(
                              width: 6,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.32,
                                    child: Text(
                                      snapshot.data['username'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  snapshot.data['state'] == 'on'
                                      ? 'Online'
                                      : getTimeData(
                                          snapshot.data['state'].toString(),
                                        ),
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Loading ...'),
                            Row(
                              children: <Widget>[
                                CircularProgressIndicator(),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  '.....',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () async {
                    var rand = Random().nextInt(10000).toString();
                    try {
                      if (await Permissions
                              .cameraAndMicrophonePermissionsGranted() &&
                          UserState == 'on') {
                        await firestore
                            .collection('calls')
                            .document(userid)
                            .setData({
                          'caller_id': userid,
                          'caller_name': Rname,
                          'caller_pic': Rpic,
                          'receiver_id': Recieverid,
                          'receiver_name': Cname,
                          'receiver_pic': Cpic,
                          'has_dialled': true,
                          'channel_id': rand,
                        });
                        await firestore
                            .collection('calls')
                            .document(Recieverid)
                            .setData({
                          'caller_id': userid,
                          'caller_name': Rname,
                          'caller_pic': Rpic,
                          'receiver_id': Recieverid,
                          'receiver_name': Cname,
                          'receiver_pic': Cpic,
                          'has_dialled': false,
                          'channel_id': rand,
                        });
                        Call call = Call(
                          callerId: userid,
                          callerName: Rname,
                          callerPic: Rpic,
                          receiverId: Recieverid,
                          receiverName: Cname,
                          receiverPic: Cpic,
                          hasDialled: true,
                          channelId: rand,
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallScreen(
                                call: call,
                              ),
                            ));
                      } else {
                        Fluttertoast.showToast(
                          msg: '$Cname need to be Online to call',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 14,
                        );
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: e.message,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.black45,
                        textColor: Colors.white,
                        fontSize: 14,
                      );
                    }

//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                      builder: (context) => VideoCall(
//                        recData: Recieverid,
//                      ),
//                    ),
//                  );
                  },
                  icon: Icon(Icons.videocam),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  picker == true
                      ? LinearProgressIndicator(
                          backgroundColor: Colors.white54,
                        )
                      : Container(),
                  Flexible(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('messages')
                            .document(userid).collection(userid).document(Recieverid)
                            .collection(Recieverid)
                            .orderBy("timestamp", descending: true)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            reverse: true,
                            controller: listScrollController,
                            itemBuilder: (context, index) {
                              return ChatData(
                                  snapshot.data.documents[index], context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4, right: 5),
                    child: Row(
                      children: <Widget>[
                        emoji
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    emoji = emoji ? false : true;
                                    textfield.requestFocus();
                                  });
                                },
                                child: Icon(
                                  Icons.keyboard,
                                  color: Colors.grey,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    emoji = emoji ? false : true;
                                    textfield.unfocus();
                                  });
                                },
                                child: Icon(
                                  Icons.insert_emoticon,
                                  color: Colors.grey,
                                ),
                              ),
                        SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: TextField(
                            controller: texteditingcontroller,
                            focusNode: textfield,
                            onTap: () {
                              setState(() {
                                emoji = false;
                              });
                            },
                            maxLines: 4,
                            minLines: 1,
                            cursorColor: Colors.greenAccent,
                            onChanged: (value) {
                              (value.length > 0 && value.trim() != '')
                                  ? writting(true)
                                  : writting(false);
                              mestext = value;
                              //Do something with the user input.
                            },
                            decoration: InputDecoration(
                              hintText: 'Type your message',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        iswritting == false
                            ? GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 210,
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white54,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.5),
                                              topRight: Radius.circular(10.5)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    getLocation();
                                                  },
                                                  child: Column(
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage: AssetImage(
                                                            'images/location.png'),
                                                      ),
                                                      Text('Location'),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: ()async {
                                                    pickFile(
                                                        await FilePicker.getFile(type: FileType.any), 'doc');
                                                  },
                                                  child: Column(
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor:
                                                        Colors.transparent,
                                                        child: Icon(
                                                          Icons.camera,
                                                          color: Colors.orange,
                                                          size: 55,
                                                        ),
                                                      ),
                                                      Text('Document'),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    pickImage(
                                                        ImageSource.gallery);
                                                  },
                                                  child: Column(
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage: AssetImage(
                                                            'images/gallery.png'),
                                                      ),
                                                      Text('Images'),
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.add_circle,
                                  color: Colors.lightBlue,
                                ),
                              )
                            : Container(),
                        SizedBox(
                          width: 6,
                        ),
                        iswritting == false
                            ? GestureDetector(
                                onTap: () => pickImage(ImageSource.camera),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                ),
                              )
                            : Container(),
                        SizedBox(
                          width: 6,
                        ),
                        iswritting
                            ? FlatButton(
                                onPressed: () async {
                                  texteditingcontroller.clear();
                                  try {
                                    await firestore
                                        .collection('messages')
                                        .document(userid)
                                        .collection(userid).document(Recieverid).collection(Recieverid)
                                        .add({
                                      'senderID': userid,
                                      'receivID': Recieverid,
                                      'message': mestext,
                                      'read' : 0,
                                      'photo': null,
                                      'timestamp':
                                          DateTime.now().toIso8601String(),
                                      'type': 'text',
//                      'number': loginuser.phoneNumber,
                                    });
                                    await firestore
                                        .collection('messages')
                                        .document(Recieverid)
                                        .collection(Recieverid).document(userid).collection(userid)
                                        .add({
                                      'senderID': userid,
                                      'receivID': Recieverid,
                                      'photo': null,
                                      'message': mestext,
                                      'read' : 0,
                                      'timestamp':
                                          DateTime.now().toIso8601String(),
                                      'type': 'text',
                                    });
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                      msg: e.message,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 5,
                                      backgroundColor: Colors.black45,
                                      textColor: Colors.white,
                                      fontSize: 14,
                                    );
                                  }

                                  //Implement send functionality.
                                },
                                child: Container(
                                  height: 33,
                                  width: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.lightBlueAccent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : FlatButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => AlertDialog(
                                      content: Container(
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.deepOrange,
                                              size: 60,
                                            ),
                                            Text(
                                              'Sorry boss, voice message sent feature is not available now, This feature will available soon',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              focusColor: Colors.deepOrange,
                                              icon: Icon(Icons.clear,
                                                  color: Colors.deepOrange),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 33,
                                  width: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.lightBlueAccent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.record_voice_over,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  emoji
                      ? EmojiPicker(
                          rows: 3,
                          columns: 7,
                          buttonMode: ButtonMode.MATERIAL,
                          recommendKeywords: ["face", "sad", "happy", "racing"],
                          numRecommended: 50,
                          onEmojiSelected: (emoji, category) {
                            setState(() {
                              iswritting = true;
                            });
                            texteditingcontroller.text =
                                texteditingcontroller.text + emoji.emoji;
                            print(emoji);
                          },
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//It's for chat, it automatic detect which chat sent by sender or me
Widget ChatData(DocumentSnapshot snapshot, context) {
  getTime(String kalu) {
    var time, stamp;
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
    return (time.toString() + kalu.substring(13, 16) + " " + stamp);
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

  return Transform.scale(
    scale: 1,
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: snapshot['senderID'] == userid
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: snapshot['type'] == 'text'
                ? MediaQuery.of(context).size.width * 0.75
                : MediaQuery.of(context).size.width * 0.45,
            child: Material(
              color: snapshot['senderID'] == userid
                  ? Colors.lightBlueAccent
                  : Colors.orange,
              elevation: 15,
              borderRadius: snapshot['senderID'] == userid
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(20),
                      topRight: Radius.circular(30),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(10),
                    ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    snapshot['type'] == 'image'
                        ? Align(
                            alignment: snapshot['senderID'] == userid
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: GestureDetector(
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
                                            content: snapshot['photo'] != null
                                                ? Image.network(
                                                    snapshot['photo'],
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
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
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'images/loading.gif'),
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          bottom: 20,
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: Container(
                                                            height: 147,
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    15.5),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black54,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30)),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'Image not Available or Uploaded, or possibly this image not uploaded due to Internet Issue',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white70),
                                                                ),
                                                                Text(
                                                                  'Otherwise, image has been removed due to small storage',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white70),
                                                                ),
                                                              ],
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ));
                              },
                              child: Align(
                                  alignment: snapshot['senderID'] == userid
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(),
                                    child: snapshot['photo'] != null
                                        ? Image.network(
                                            snapshot['photo'],
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
                                                  backgroundColor:
                                                      Colors.blueGrey,
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
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    'images/loading.gif'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Text(
                                                  'Image Not Uploaded',
                                                  style: TextStyle(
                                                      backgroundColor:
                                                          Colors.black54,
                                                      color: Colors.orange),
                                                ),
                                              ),
                                            ),
                                          ),
                                  )),
                            ),
                          )
                        : snapshot['type'] == 'location'
                            ? Align(
                                alignment: snapshot['senderID'] == userid
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    try {
                                      _launchUniversalLinkIos(
                                          'http://maps.google.com/maps?q=${snapshot['latt']},${snapshot['long']}');
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.location_on, color: Colors.redAccent, size: 45,),
                                        SizedBox(width: 10,),
                                        Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : snapshot['type']=='doc'
                                ?Align(
                      alignment: snapshot['senderID'] == userid
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: GestureDetector(
                        onTap: (){
                          _launchUniversalLinkIos(snapshot['photo']);
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.insert_drive_file,size: 40,color: Colors.green,),
                                SizedBox(width: 10,),
                                Text('Document',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 16),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                                  :Align(
                                alignment: snapshot['senderID'] == userid
                                    ? Alignment.topLeft
                                    : Alignment.topCenter,
                                child: SelectableText(
                                  snapshot['message'] == null
                                      ? 'net probllem'
                                      : snapshot['message'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                    SizedBox(
                      height: 4,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
//                            getTime(snapshot['timestamp'].toString()),

                            getTime(snapshot['timestamp'].toString()),
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(
                            width: 5,
                          ),
//                          Icon(status=='sent'?Icons.check:status=='seen'? Icons.check_circle: Icons.check_circle_outline,
//                            color: status=='seen'?Colors.greenAccent: Colors.white,
//                            size: 15,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
