import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatzzchat/call/pickup/pickup_screen.dart';
import 'package:whatzzchat/constant.dart';
import 'package:whatzzchat/widget/callData.dart';
import 'package:whatzzchat/widget/call_methods.dart';
class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();
  PickupLayout({this.scaffold});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callStream(uid: uId),
      builder: (context,snapshot){
        if(snapshot.hasData && snapshot.data.data!=null){
          Call call = Call.fromMap(snapshot.data.data);
          if(!call.hasDialled){
            return PickupScreen(call: call,);
          }else{
            return scaffold;
          }
        }else{
          return scaffold;
        }
      },
    );
  }
}
