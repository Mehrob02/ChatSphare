// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
enum MessageType{text,file,image,video,audio,link,code}
enum Emote{
  emote_smile, //😁
  emote_laugh,//🤣
  emote_sad,//😢
  emote_face_no_month,//😶
  emote_smile_sunglasses, //😎
  emote_smile_wink, //😉
  emote_cry, //😭
  emote_nerd, //🤓
  emote_angry, //😡
  emote_head_expload, //🤯
  emote_scary, //😱
  emote_sleep_zzz, //😴
  emote_sleep, //😪
  emote_neutral_face, //😐
  emote_confused, //😕
  emote_confused_eyes, //😵‍💫
  emote_monocle, //🧐
  emote_cold, //🥶
  emote_sweat, //🥵
  emote_silent, //🤫
  emote_sick_flu, //🤧
  emote_sick, //🤒
  emote_sick_eyes, //🤢
  emote_vomit, //🤮
  emote_face_money, //🤑
  emote_face_in_cloud, //😶‍🌫️
  emote_deamon, //😈
  emote_eyes, //👀
  emote_thumbs_up, //👍
  emote_thumbs_down, //👎
  emote_clap, //👏
  emote_hand_wave, //👋
  emote_hand_shake, //🤝
  emote_hand_cool, //🤟
  emote_hand_rock, //🤘
  emote_hand_ok, //👌
  emote_fire, //🔥
  emote_skull, //☠️
  emote_heart, //❤️
  emote_heart2, //💕
  }
  Map <Emote, String> emotetoMap={
  Emote.emote_smile:"😁",
  Emote.emote_laugh:"🤣",
  Emote.emote_sad:"😢",
  Emote.emote_face_no_month:"😶", 
  Emote.emote_smile_sunglasses:"😎",
  Emote.emote_smile_wink:"😉",
  Emote.emote_cry:"😭",
  Emote.emote_nerd:"🤓", 
  Emote.emote_angry:"😡",
  Emote.emote_head_expload:"🤯",
  Emote.emote_scary:"😱",
  Emote.emote_sleep_zzz:"😴",
  Emote.emote_sleep:"😪",
  Emote.emote_neutral_face:"😐",
  Emote.emote_confused:"😕",
  Emote.emote_confused_eyes:"😵‍💫",
  Emote.emote_monocle:"🧐",
  Emote.emote_cold:"🥶",
  Emote.emote_sweat:"🥵",
  Emote.emote_silent:"🤫",
  Emote.emote_sick_flu:"🤧",
  Emote.emote_sick:"🤒",
  Emote.emote_sick_eyes:"🤢",
  Emote.emote_vomit:"🤮",
  Emote.emote_face_money:"🤑",
  Emote.emote_face_in_cloud:"😶‍🌫️",
  Emote.emote_deamon:"😈",
  Emote.emote_eyes:"👀",
  Emote.emote_thumbs_up:"👍",
  Emote.emote_thumbs_down:"👎",
  Emote.emote_clap:"👏", 
  Emote.emote_hand_wave:"👋",
  Emote.emote_hand_shake:"🤝",
  Emote.emote_hand_cool:"🤟",
  Emote.emote_hand_rock:"🤘",
  Emote.emote_hand_ok:"👌",
  Emote.emote_fire:"🔥",
  Emote.emote_skull:"☠️", 
  Emote.emote_heart:"❤️",
  Emote.emote_heart2:"💕",
  };
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