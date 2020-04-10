import 'package:flutter/material.dart';
import 'package:whatzzchat/widget/callData.dart';
import 'package:whatzzchat/widget/call_methods.dart';
import 'package:whatzzchat/widget/permision.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import '../call_screen.dart';

class PickupScreen extends StatefulWidget {
  final Call call;
  PickupScreen({this.call});
  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  AssetsAudioPlayer audio;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audio = AssetsAudioPlayer();
    audio.open("audios/ringtone.mp3");
    audio.playOrPause();
    audio.play();
    audio.loop = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audio.stop();
    audio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Incomming call ...',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 50,
              ),
              CircleAvatar(
                radius: 60,
                backgroundImage: widget.call.callerPic != null
                    ? NetworkImage(widget.call.callerPic)
                    : AssetImage('images/loadiing.gif'),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.call.callerName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 75,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      audio.stop();
                      audio.dispose();
                      await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  call: widget.call,
                                ),
                              ))
                          : {};
                    },
                    icon: Icon(
                      Icons.call,
                      size: 45,
                      color: Colors.green,
                    ),
                    alignment: Alignment.center,
                  ),
                  IconButton(
                    onPressed: () async {
                      await callMethods.endCall(call: widget.call);
                    },
                    icon: Icon(
                      Icons.call_end,
                      size: 45,
                      color: Colors.red,
                    ),
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
