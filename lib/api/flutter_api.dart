import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FlutterApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();
    final fMCToken = await _firebaseMessaging.getToken();
    debugPrint(fMCToken.toString());
    } catch (e) {
      debugPrint("fcm");
    }
    
  }
}
