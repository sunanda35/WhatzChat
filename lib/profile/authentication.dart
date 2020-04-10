import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whatzzchat/chat/public.dart';
import 'package:whatzzchat/constant.dart';
import 'package:whatzzchat/profile/pmade.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:country_code_picker/country_code_picker.dart';

class chatapp extends StatefulWidget {
  static String id = 'auth';
  @override
  _chatappState createState() => _chatappState();
}

FirebaseUser user;
final phoneNumber = TextEditingController();
String CountryCode;
bool progress = false;

class _chatappState extends State<chatapp> {
  final Future<FirebaseUser> loginuser = FirebaseAuth.instance.currentUser();
  final auth = FirebaseAuth.instance;

  String smsCode;
  String verificationCode;
  bool authuserdata;
  final Firestore firestore = Firestore.instance;
  String prePhone;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    refreshContact();
  }

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        AuthResult result = await auth.signInWithCredential(credential);
        Navigator.of(context).pop();
        user = result.user;
        if (user != null) {
          setState(() {
            progress = false;
          });
          if (prePhone == phone) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ChatPublic()));
            setState(() {
              progress = false;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Pmade();
                },
              ),
            );
          }
        } else {
          setState(() {
            progress = false;
          });
          Fluttertoast.showToast(
            msg: "Something Goes Wrong",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            fontSize: 14,
          );
        }
        //this would call when the auto retrival code is useing
      },
      verificationFailed: (AuthException exception) {
        Fluttertoast.showToast(
          msg: exception.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 14,
        );
        setState(() {
          progress = false;
        });
      },
      codeSent: (String verificationId, [int forceResendingToken]) {
        setState(() {
          progress = false;
        });
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return ModalProgressHUD(
                inAsyncCall: progress,
                child: AlertDialog(
                  content: Container(
                    height: 300,
                    color: Colors.white30,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Enter OTP Number',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            child: TextField(
                              onChanged: (value) {
                                smsCode = value;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Material(
                            elevation: 5.0,
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20.0),
                            child: MaterialButton(
                              onPressed: () async {
                                setState(() {
                                  progress = true;
                                });
                                try {
                                  AuthCredential credential =
                                  PhoneAuthProvider.getCredential(
                                      verificationId: verificationId,
                                      smsCode: smsCode);
                                  AuthResult result = await auth
                                      .signInWithCredential(credential);
                                  FirebaseUser user = result.user;
                                  if (user != null) {
                                    setState(() {
                                      progress = false;
                                    });
                                    if (prePhone == phone) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatPublic()));
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Pmade();
                                          },
                                        ),
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      progress = false;
                                    });
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                      msg:
                                      "Something Went Wrong, Please Try Again!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black45,
                                      textColor: Colors.white,
                                      fontSize: 14,
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    progress = false;
                                  });
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
                              },
                              height: 20,
                              minWidth: 100,
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 1,
                              child: Container(color: Colors.black38,),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Did\'t Get OTP? ',
                                style: TextStyle(color: Colors.black45),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Material(
                                elevation: 2.0,
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10.0),
                                child: MaterialButton(
                                  onPressed: () => loginUser(CountryCode + phoneNumber.text, context),
                                  child: Text('Re-Send'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Material(
                                elevation: 3.0,
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(5.0),
                                child: MaterialButton(onPressed: () =>
                                    loginUser(
                                        CountryCode + phoneNumber.text,
                                        context),
                                    child: Text('Re-Enter Number')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

            });
      },
      codeAutoRetrievalTimeout: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool button = false;
    return WillPopScope(
      onWillPop: ()async =>onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppName),
          centerTitle: true,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: ModalProgressHUD(
              inAsyncCall: progress,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        height: 300,
                        child: Image.asset('images/slogo.png'),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Material(
                      elevation: 20,
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                'Country: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black45),
                              ),
                              CountryCodePicker(
                                onInit: (value) {
                                  CountryCode = value.toString();
                                },
                                onChanged: (value) {
                                  CountryCode = value.toString();
                                },
                                initialSelection: 'IN',
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: phoneNumber,
                              onChanged: (value) {},
                              maxLength: 11,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'Enter Your Number',
                                  hintText: 'e.g. 1234567809',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Material(
                            elevation: 6.0,
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(30),
                            child: MaterialButton(
                              disabledColor: Colors.redAccent,
                              onPressed: () {
                                setState(() {
                                  progress = true;
                                });
                                loginUser(CountryCode + phoneNumber.text, context);
                              },
                              height: 40,
                              minWidth: 180.0,
                              child: Text(
                                'Get OTP',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
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
      ),
    );
  }
}
