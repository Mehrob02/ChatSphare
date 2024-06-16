import 'package:cloud_firestore/cloud_firestore.dart';
enum MessageType{text,file,image,video,audio,link}
class Message{
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;
  final String? replyTo;
  final String? replyToId;
  final MessageType messageType;

  Message(this.senderId, this.senderEmail, this.receiverId, this.timestamp, this.message, this.replyTo, this.messageType, this.replyToId,);

 Map<String,dynamic> toMap(){
  return {
    'senderId':senderId,
    'senderEmail':senderEmail,
    'receiverId':receiverId,
    'message':message,
    'timestamp':timestamp,
    'messageType':messageType.name,
    if(replyTo!=null)'replyTo':replyTo,
    if(replyToId!=null)'replyToId':replyToId
  };
 }
}