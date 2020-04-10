import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:whatzzchat/constant.dart';
import 'package:whatzzchat/widget/callData.dart';
import 'package:whatzzchat/widget/call_methods.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends StatefulWidget {
  final Call call;
  CallScreen({
    this.call,
});
  @override
  _CallScreenState createState() => _CallScreenState();
}

 class _CallScreenState extends State<CallScreen> {
   CallMethods callMethods = CallMethods();
   StreamSubscription streamSubscription;
   final CollectionReference callCollection =
   Firestore.instance.collection('calls');

   static final _users = <int>[];
   final _infoStrings = <String>[];
   bool muted = false;

   @override
   void dispose() {
     // clear users
     _users.clear();
     // destroy sdk
     AgoraRtcEngine.leaveChannel();
     AgoraRtcEngine.destroy();
     super.dispose();
   }

   @override
   void initState() {
     super.initState();
     // initialize agora sdk
     initialize();
     addPostFrameCallback();
   }


   void addPostFrameCallback() {
     SchedulerBinding.instance.addPostFrameCallback((Decoration) {
       streamSubscription =
           callMethods.callStream(uid: uId).listen((DocumentSnapshot ui) {
             switch (ui.data) {
               case null:
                 Navigator.pop(context);
                 break;

               default:
                 break;
             }
           });
     });
   }


   Future<void> initialize() async {
     if (agora_AppId.isEmpty) {
       setState(() {
         _infoStrings.add(
           'APP_ID missing, please provide your APP_ID in settings.dart',
         );
         _infoStrings.add('Agora Engine is not starting');
       });
       return;
     }

     await _initAgoraRtcEngine();
     _addAgoraEventHandlers();
     await AgoraRtcEngine.enableWebSdkInteroperability(true);
     await AgoraRtcEngine.setParameters(
         '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
     await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);
   }

   /// Create agora sdk instance and initialize
   Future<void> _initAgoraRtcEngine() async {
     await AgoraRtcEngine.create(agora_AppId);
     await AgoraRtcEngine.enableVideo();
   }

   /// Add agora event handlers
   void _addAgoraEventHandlers(){
     AgoraRtcEngine.onError = (dynamic code) {
       setState(() {
         final info = 'onError: $code';
         _infoStrings.add(info);
         sleep(const Duration(seconds: 5));
         callMethods.endCall(call: widget.call);
       });
     };

     AgoraRtcEngine.onJoinChannelSuccess = (
         String channel,
         int uid,
         int elapsed,
         ) {
       setState(() {
         final info =widget.call.hasDialled==false? {}: widget.call.receiverName+'\'s phone ringing';
         _infoStrings.add(info);
       });
     };

     AgoraRtcEngine.onLeaveChannel = () {
       setState(() {
         _infoStrings.add(widget.call.receiverName+' hangged-up');
         _users.clear();
       });
     };

     AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
       setState(() {
         final info =widget.call.hasDialled==false? 'Now You connected with '+widget.call.callerName : widget.call.receiverName+' Picked up call';
         _infoStrings.add(info);
         _users.add(uid);
       });
     };

     AgoraRtcEngine.onUserOffline = (int uid, int reason) {
       setState(() {
         final info = widget.call.hasDialled==false?widget.call.receiverName+' getting some Internet issue or hangged-up':widget.call.callerName+' getting some Internet issue or hangged-up';
         _infoStrings.add(info);
         _users.remove(uid);
       });
     };

     AgoraRtcEngine.onFirstRemoteVideoFrame = (
         int uid,
         int width,
         int height,
         int elapsed,
         ) {
       setState(() {
         final info = 'Video call started';
         _infoStrings.add(info);
       });
     };
   }

   /// Helper function to get list of native views
   List<Widget> _getRenderViews() {
     final List<AgoraRenderWidget> list = [
       AgoraRenderWidget(0, local: true, preview: true),
     ];
     _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
     return list;
   }

   /// Video view wrapper
   Widget _videoView(view) {
     return Expanded(child: Container(child: view));
   }

   /// Video view row wrapper
   Widget _expandedVideoRow(List<Widget> views) {
     final wrappedViews = views.map<Widget>(_videoView).toList();
     return Expanded(
       child: Row(
         children: wrappedViews,
       ),
     );
   }

   /// Video layout wrapper
   Widget _viewRows() {
     final views = _getRenderViews();
     switch (views.length) {
       case 1:
         return Container(
             child: Column(
               children: <Widget>[_videoView(views[0])],
             ));
       case 2:
         return Container(
             child: Column(
               children: <Widget>[
                 _expandedVideoRow([views[1]]),
                 _expandedVideoRow([views[0]]),
               ],
             ));
       default:
     }
     return Container();
   }

   /// Toolbar layout
   Widget _toolbar() {
     return Container(
       alignment: Alignment.bottomCenter,
       padding: const EdgeInsets.symmetric(vertical: 48),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           RawMaterialButton(
             onPressed: _onToggleMute,
             child: Icon(
               muted ? Icons.mic_off : Icons.mic,
               color: muted ? Colors.white : Colors.blueAccent,
               size: 20.0,
             ),
             shape: CircleBorder(),
             elevation: 2.0,
             fillColor: muted ? Colors.blueAccent : Colors.white,
             padding: const EdgeInsets.all(12.0),
           ),
           RawMaterialButton(
             onPressed: () => _onCallEnd(context),
             child: Icon(
               Icons.call_end,
               color: Colors.white,
               size: 35.0,
             ),
             shape: CircleBorder(),
             elevation: 2.0,
             fillColor: Colors.redAccent,
             padding: const EdgeInsets.all(15.0),
           ),
           RawMaterialButton(
             onPressed: _onSwitchCamera,
             child: Icon(
               Icons.switch_camera,
               color: Colors.blueAccent,
               size: 20.0,
             ),
             shape: CircleBorder(),
             elevation: 2.0,
             fillColor: Colors.white,
             padding: const EdgeInsets.all(12.0),
           )
         ],
       ),
     );
   }

   /// Info panel to show logs
   Widget _panel() {
     return Container(
       padding: const EdgeInsets.symmetric(vertical: 67),
       alignment: Alignment.bottomCenter,
       child: FractionallySizedBox(
         heightFactor: 0.5,
         child: Container(
           padding: const EdgeInsets.symmetric(vertical: 48),
           child: ListView.builder(
             reverse: true,
             itemCount: _infoStrings.length,
             itemBuilder: (BuildContext context, int index) {
               if (_infoStrings.isEmpty) {
                 return null;
               }
               return Padding(
                 padding: const EdgeInsets.symmetric(
                   vertical: 3,
                   horizontal: 10,
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Flexible(
                       child: Container(
                         padding: const EdgeInsets.symmetric(
                           vertical: 2,
                           horizontal: 5,
                         ),
                         decoration: BoxDecoration(
                           color: Color(0xFFFFECB3),
                           borderRadius: BorderRadius.circular(5),
                         ),
                         child: Text(
                           _infoStrings[index],
                           style: TextStyle(color: Colors.blueGrey),
                         ),
                       ),
                     )
                   ],
                 ),
               );
             },
           ),
         ),
       ),
     );
   }

   void _onCallEnd(BuildContext context)async {
    await callMethods.endCall(call: widget.call);
    Navigator.popUntil(context, ModalRoute.withName('chatting'));
   }

   void _onToggleMute() {
     setState(() {
       muted = !muted;
     });
     AgoraRtcEngine.muteLocalAudioStream(muted);
   }

   void _onSwitchCamera() {
     AgoraRtcEngine.switchCamera();
   }

   @override
   Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: null,
       child: Scaffold(
         backgroundColor: Colors.black,
         body: Center(
           child: Stack(
             children: <Widget>[
               _viewRows(),
               _panel(),
               _toolbar(),
             ],
           ),
         ),
       ),
     );
   }

}