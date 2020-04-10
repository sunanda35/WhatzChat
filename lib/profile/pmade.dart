import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatzzchat/chat/public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatzzchat/widget/appMethod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Pmade extends StatefulWidget {
  Pmade({this.phone});
  final phone;
  @override
  _PmadeState createState() => _PmadeState();
}
bool progress=false;
class _PmadeState extends State<Pmade> {
  final firestore = Firestore.instance;
  final auth = FirebaseAuth.instance;
  File image;
  String userid;
  String name;
  String phone;
  String username;
  String status;
  String photo;
  String state='on';

  @override
  void initState() {
    super.initState();
    LoginData();
    auth.currentUser().then((loginuser){
      setState(() {
        userid=loginuser.uid;
        phone=loginuser.phoneNumber;
      });
    });
  }
  LoginData()async{
    SharedPreferences login = await SharedPreferences.getInstance();
    login.setBool('loginData', true);
  }

  proImage(@required ImageSource source)async{
    File selectedImage = await Profile.proimage(source: source,uid: userid);
    if(selectedImage!=null){
      setState(() {
        progress=true;
      });
    }
    String purl = await uploadProImage(selectedImage,userid);
    setState(() {
      image=selectedImage;
      photo=purl;
      progress=false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: progress,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      'Your Profile InFo',
                      style: TextStyle(
                        letterSpacing: 2,
                        color: Colors.greenAccent,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 12,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      width: 260,
                      child: Text(
                        'Give your name and profile photo, what can see everyone. It can be change in future', style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400
                      ),),),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: (){
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context){
                              return AlertDialog(
                                content: Container(
                                  height: 70,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.pop(context);
                                          proImage(ImageSource.gallery);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.image,size: 50,color: Colors.deepOrange,),
                                            Text('Gallery'),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 50,),
                                      GestureDetector(
                                        onTap:(){
                                          Navigator.pop(context);
                                          setState(() {
                                            progress=false;
                                          });
                                          proImage(ImageSource.camera);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.camera_alt,size: 50,color: Colors.green,),
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
                      child:CircleAvatar(
                        radius: 55,
                        backgroundImage: AssetImage('images/profile.jpg'),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.add_circle_outline,
                            color: Colors.blueAccent,
                            size: 33,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: TextField(
                      onChanged: (value){
                        username=value;
                      },
                      maxLength: 15,
                      decoration: InputDecoration(
                          labelText: 'Username',
                          icon: Icon(Icons.perm_identity)
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: TextField(
                      onChanged: (value){
                        status=value;
                      },
                      decoration: InputDecoration(
                          labelText: 'Status',
                          icon: Icon(Icons.border_color)
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment:Alignment.center,
                          child: Material(
                            elevation: 5.0,
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20.0),
                            child: MaterialButton(
                              onPressed: ()async{
                                if(username==null ){
                                  Fluttertoast.showToast(
                                      msg: 'Username & Status field can\'t be empty',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black45,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }else if(status==null ) {
                                  Fluttertoast.showToast(
                                      msg: 'Username & Status field can\'t be empty',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black45,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }else{
                                  setState(() {
                                    progress=true;
                                  });
                                  await firestore.collection('users').document(userid).setData({
                                    "uid" : userid,
                                    'phone' : phone,
                                    'username': username,
                                    'profile' : photo,
                                    'status' : status,
                                    'state' : state,
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatPublic(),),);
                                }
                                setState(() {
                                  progress=false;
                                });
                              },
                              height: 20,
                              minWidth: 100,
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
