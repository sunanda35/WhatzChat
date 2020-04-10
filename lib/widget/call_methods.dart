import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatzzchat/widget/callData.dart';


class CallMethods {
  final CollectionReference callCollection =
  Firestore.instance.collection('calls');

  Stream<DocumentSnapshot> callStream({String uid}) =>
      callCollection.document(uid).snapshots();

  Future<bool> endCall({Call call}) async {
    try {
      await callCollection.document(call.callerId).delete();
      await callCollection.document(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}