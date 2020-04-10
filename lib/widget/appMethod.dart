import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as im;

final Future<FirebaseUser> loginuser = FirebaseAuth.instance.currentUser();
final firestore = Firestore.instance;
StorageReference storageReferencetoUpload;

bool isLoggedIn() {
  if (FirebaseAuth.instance.currentUser() != null) {
    return true;
  } else {
    return false;
  }
}
String userid;

void addOnExitListener({String userid}){
  FirebaseAuth.instance.currentUser().then((loginuser) {
    userid = loginuser.uid;
    print(loginuser.uid);
  });
  firestore.collection('users').document(userid).updateData({
    'state' : DateTime.now().toIso8601String().substring(0,17),
  });
}

void uploadImage(File image, String recivID, String userID)async{         //add image in massage function for chatting
  String url =await Utils.uploadImages(image);
  await firestore
      .collection('messages')
      .document(userID)
      .collection(userID).document(recivID).collection(recivID)
      .add({
    'senderID': userID,
    'receivID': recivID,
    'photo' : url,
    'message': '',
    'timestamp': DateTime.now().toIso8601String(),
    'type': 'image',
  });
  await firestore
      .collection('messages')
      .document(recivID)
      .collection(recivID).document(userID).collection(userID)
      .add({
    'senderID': userID,
    'receivID': recivID ,
    'photo' : url,
    'message': '',
    'timestamp': DateTime.now().toIso8601String(),
    'type': 'image',
  });
}

class Utils{               //all image fucktions here in a class Utils for single and group chatting
 static Future<String> uploadImages(File image)async{
    try{
      print(image);
      storageReferencetoUpload = FirebaseStorage.instance.ref().child('messages/${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask = await storageReferencetoUpload.putFile(image);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      print(url);
      return url;
    }catch(x){
      print(x);
      return null;
    }
  }

static Future<File> pickImage({@required ImageSource source})async{
  File selectedImage = await ImagePicker.pickImage(source: source);
  return compressImage(selectedImage);
}
static Future<File> compressImage(File imageCompress)async{
  final temdir = await getTemporaryDirectory();
  final path = temdir.path;
  int random = Random().nextInt(10000);
  im.Image image = im.decodeImage(imageCompress.readAsBytesSync());
  return new File('$path/img_$random.jpg')..writeAsBytesSync(im.encodeJpg(image,quality: 45));
}


}



Future uploadProImage(File image, String userID)async{         //add image to profile
  String url =await Profile.uploadProImages(image, userID);
  return url;
}

class Profile{
  static Future<File> proimage({@required ImageSource source,String uid})async{
    File selectedImage = await ImagePicker.pickImage(source: source);
    return compressProImage(selectedImage,uid);
  }
  static Future<File> compressProImage(File imageCompress,String userId)async{
    final temdir = await getTemporaryDirectory();
    final path = temdir.path;
    im.Image image = im.decodeImage(imageCompress.readAsBytesSync());
    return new File('$path/pro_$userId.jpg')..writeAsBytesSync(im.encodeJpg(image,quality: 35));
  }

  static Future<String> uploadProImages(File image, String userid)async{
    try{
      final StorageReference storageReference = FirebaseStorage.instance.ref().child('profile/${userid}');
      storageReference.delete();                   //to delete previous profile photo

      storageReferencetoUpload = FirebaseStorage.instance.ref().child('profile/${userid}');
      StorageUploadTask storageUploadTask = await storageReferencetoUpload.putFile(image);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    }catch(x){
      print(x);
      return null;
    }
  }
}