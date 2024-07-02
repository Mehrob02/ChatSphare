import 'package:cloud_firestore/cloud_firestore.dart';
enum MessageType{text,file,image,video,audio,link,code}
class Message{
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;
  final String? replyTo;
  final String? replyToId;
  final MessageType messageType;
  final String? fileName;

  Message(this.senderId, this.senderEmail, this.receiverId, this.timestamp, this.message, this.replyTo, this.messageType, this.replyToId,{this.fileName});

 Map<String,dynamic> toMap(){
  switch (messageType) {
    case MessageType.file:
    case MessageType.video:  
    return {
    'senderId':senderId,
    'senderEmail':senderEmail,
    'receiverId':receiverId,
    'message':message,
    'timestamp':timestamp,
    'isRead':false,
    'messageType':messageType.name,
    'fileName':fileName??'undefined',
    if(replyTo!=null)'replyTo':replyTo,
    if(replyToId!=null)'replyToId':replyToId
  };
    default:
     return {
    'senderId':senderId,
    'senderEmail':senderEmail,
    'receiverId':receiverId,
    'message':message,
    'timestamp':timestamp,
    'isRead':false,
    'messageType':messageType.name,
    if(replyTo!=null)'replyTo':replyTo,
    if(replyToId!=null)'replyToId':replyToId
  };
  }
 
 }
}