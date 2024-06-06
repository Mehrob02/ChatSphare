import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final fMCToken = await _firebaseMessaging.getToken();
      await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "email": email,
        "uid": userCredential.user!.uid,
        "lastVisited": Timestamp.now(),
      });
      try {
        await firebaseFirestore
            .collection("users_tokens")
            .doc(userCredential.user!.uid)
            .set({
          "token": fMCToken,
        });
      } catch (e) {
        debugPrint("token error");
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code.toString());
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String nickName) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final fMCToken = await _firebaseMessaging.getToken();
      await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "email": email,
        "uid": userCredential.user!.uid,
        "lastVisited": Timestamp.now(),
      });
      try {
        await firebaseFirestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
            .doc("my_contacts")
            .set({"contacts": []});
        try {
          await firebaseFirestore
              .collection("nickNames")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            "nickName": nickName,
          });
        } on FirebaseException catch (e) {
          debugPrint("$e nickname");
        }
      } catch (e) {
        debugPrint("token erroryyyy");
      }
      try {
        await firebaseFirestore
            .collection("users_tokens")
            .doc(userCredential.user!.uid)
            .set({
          "token": fMCToken,
        });
      } catch (e) {
        debugPrint("token error");
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code.toString());
      throw Exception(e.code);
    }
  }

  // Future<bool> isOnline()async{

  // }
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
