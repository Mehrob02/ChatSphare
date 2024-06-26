// ignore_for_file: non_constant_identifier_names, unused_import, unused_field, prefer_const_declarations

import 'dart:convert';

import 'package:chatsphere/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatService extends ChangeNotifier{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> sendMessage(String receiverId, String message, String? replyTo,MessageType messageType, String? replyToId,{String? fileName})async{
    final String currentUserId = firebaseAuth.currentUser!.uid;
    final String currentUserEmail = firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(currentUserId, currentUserEmail, receiverId, timestamp, message, replyTo, messageType, replyToId, fileName: fileName);

    List <String> ids= [currentUserId,receiverId];
    ids.sort();
    String ChatRoomId = ids.join("_");

   DocumentReference messageRef = await firebaseFirestore.collection("chat_rooms").doc(ChatRoomId).collection('messages').add(newMessage.toMap());
    String messageId = messageRef.id;
    debugPrint("Message sent with ID: $messageId");
  }
  Future<void> removeMessage(String userId, String otherUserId, String messageId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    await firebaseFirestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }
  String toMonth(String monthNumber){
    switch(monthNumber){
      case "01":
      return "January";
      case "02":
      return "February";
      case "03":
      return "March";
      case "04":
      return "April";
      case "05":
      return "May";
      case "06":
      return "June";
      case "07":
      return "July";
      case "08":
      return "August";
      case "0z9":
      return "September";
      case "10":
      return "October";
      case "11":
      return "November";
      case "12":
      return "December";
      default:
      return "";
  }
  }
  Future<void> sendNotification(String serverKey, String message, String tokenTo) async {
  final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  try {
    // Получаем никнейм пользователя из Firestore
    final nickNameDoc = await firebaseFirestore.collection("nickNames").doc(firebaseAuth.currentUser!.uid).get();
    final nickName = nickNameDoc.data()?['nickName'];

    final Map<String, dynamic> notification = {
      'notification': {
        'title': nickName??"nickName", // Используем полученный никнейм
        'body': message,
      },
      'to': tokenTo, // Токен целевого устройства
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(notification),
    );

    if (response.statusCode == 200) {
      debugPrint('Уведомление успешно отправлено');
    } else {
      debugPrint('Ошибка при отправке уведомления: ${response.reasonPhrase}');
    }
  } catch (e) {
    debugPrint('Ошибка при отправке уведомления: $e');
  }
}
  Stream<QuerySnapshot> getMessages(String userId,String otherUserId){
    List <String> ids =[userId,otherUserId];
    ids.sort();
    String ChatRoomId = ids.join("_");
    return firebaseFirestore.collection("chat_rooms").doc(ChatRoomId).collection("messages").orderBy("timestamp", descending: false).snapshots();
  }
}