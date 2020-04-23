# WhatzzChat using Flutter
Online Chatting application like `Whatsapp` or `Skype`. 

This app has mechanism using `Functions` that every message will delete after 24 hours, and pre-profile photo will be deleted after successfully updated new profie photo.
Free to use, any person can do anything with it, 

## Quick Start
  - `Login` using your phone number
  - Add `Your photo(if you want), username and status`.
  - Then you can start `chatting`.
  - You can sent *`text, image, file, emoji, current location`* etc. 
  - You can also **`video call`** with anyone.
  
<img src="https://github.com/sunanda35/WhatzChat/blob/master/screenshots/Screenshot_2020-04-06-03-02-51-310_com.sunanda.whatzzchat.jpg?raw=true" width="25%"><img src="https://github.com/sunanda35/WhatzChat/blob/master/screenshots/Screenshot_2020-04-06-03-01-46-557_com.sunanda.whatzzchat.jpg?raw=true" width="25%"><img src="https://github.com/sunanda35/WhatzChat/blob/master/screenshots/Screenshot_2020-04-06-03-00-00-872_com.sunanda.whatzzchat.jpg?raw=true" width="25%"><img src="https://github.com/sunanda35/WhatzChat/blob/master/screenshots/Screenshot_2020-04-06-03-01-15-088_com.sunanda.whatzzchat.jpg?raw=true" width="25%">

## This app use
 - *`Firebase firestore`* to store messages and data.
 - *`Firebase storage`* to store photo and file.
 - *`Firebase Function`* to delete ever messages after 24 hours.
 - *`Agora`* for giveing video calling feature, but here you have to give your own agora appid.
 ```
 const APP_ID = "";
 ```
   - Change **`const agora_ID = " ";`** in your *`constant.dart`* file. GET Agora APP ID from [Agora.io](https://www.agora.io/en/).
   - **`Flutter packages`** every packages used, all are in stable version. If you change any version, disfunctionality may occur.<br>

## Project Set-up
   - ### Add json file to this
       Add json file which you will get from firebase when you add your app on firebase. Download it from firebase.<br>
       Add this to path on **`project_name\android\app\`** file.
   - ### Add Sha-1 Key
        Add `sha-1 key` to you firebase project settings.<br>  
        Run on Terminal: *`keytool -list -v -keystore "[Keystore file location]\debug.keystore" -alias androiddebugkey -storepass android -keypass android`*  
        To get `sha-1 key` on android studio, go to `project_name\android\app\src\build.gradle`<br>  
        Click on `Open for Editing on Android Studio`<br>  
        Go to `:app\Tasks\android\signingReport`  

## ERROR handling
 - ### Permission 
      In permission handler sometimes giving some error when user denied to give permission, it throws some unknown error, [solve](https://pub.dartlang.org/packages/permission_handler).
 - ### Black Screen on video call
      if your MainActivity extends `io.flutter.embedding.android.FlutterActivity` and override the configureFlutterEngine function
      please don't forget add `super.configureFlutterEngine(flutterEngine)`<br>
      please don't add `GeneratedPluginRegistrant.registerWith(flutterEngine)`
 - ### Android Release Crash
      it causes by code obfuscation because of flutter set *`android.enableR8=true`* by the default<br>
      Add the following line in the **`app/proguard-rules.pro`** file to prevent code obfuscation:
      
      ```
      -keep class io.agora.**{*;},
      ```
 - ### iOS Memory Leak
      Actually I don't get any solution of that. If you got any solution of that, please let me know here.
 - ### Widget 
      Some resources can help you really<br>
       It's will help you to get rid of widget problem [online documentation](https://flutter.dev/docs)
       Cookbook: Useful [Flutter Examples](https://flutter.dev/docs/cookbook)
       Test run on online [Run Code](https://flutter.dev/docs/get-started/codelab)
