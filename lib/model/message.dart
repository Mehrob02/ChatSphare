import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;

  Message(this.senderId, this.senderEmail, this.receiverId, this.timestamp, this.message, );

 Map<String,dynamic> toMap(){
  return {
    'senderId':senderId,
    'senderEmail':senderEmail,
    'receiverId':receiverId,
    'message':message,
    'timestamp':timestamp,
    
  };
 }
}