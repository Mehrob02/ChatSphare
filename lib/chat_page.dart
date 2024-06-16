// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables, unused_import

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/chat_audio_player.dart';
import 'package:chatsphere/message_box.dart';
import 'package:chatsphere/model/message.dart';
import 'package:chatsphere/mytests/testfile.dart';
import 'package:chatsphere/mytests/testfile2.dart';
import 'package:chatsphere/record.dart';
import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:chatsphere/video_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'file_view.dart';
import 'notification_body.dart';
import 'services/settings/settings_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.reciveruserEmail, required this.reciverUserID});
  final String reciveruserEmail;
  final String reciverUserID;
  @override
  State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();
  final ChatService chatService =ChatService();
  final SettingsService settingsService =SettingsService();
  final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FlutterListViewController controller = FlutterListViewController();
  String? replyingToMessage;
  String? replyToId;
 MessageType defineType(String value){
  switch (value) {
    case "text":
    return MessageType.text;
    case "file":
    return MessageType.file;
    case "image":
    return MessageType.image;
    case "video":
    return MessageType.video;
    case "audio":
    return MessageType.audio;
    case "link":
    return MessageType.link;
    default:
    return MessageType.text;
  }
 }
 
   Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery); 

    if (pickedImage != null) {
     
      File imageFile = File(pickedImage.path);
      
      final storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);

      String imageUrl = await storageReference.getDownloadURL();
      await chatService.sendMessage(widget.reciverUserID, imageUrl,replyingToMessage, MessageType.image,replyToId);
      try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
    final token = tokenDoc.data()?['token'];
      chatService.sendNotification(
       'AAAA3Bg6cyc:APA91bEsBgNbM3DmcopwxkbVpgF3LOGvLXj2rTWP2uegePZCa7pcGnYiQfpSHQ96f3Y6GzAQKrss2UoABLBSY1Iz8LHe-L4mZAt5MJklE-sW5dTnxFAvMIZ351vS9PiDyU6vD5JPGsJA' ,
         "Sent an image",
          token);
     } catch (e) {
       debugPrint("notification didn't sent");
     }
    }
     if(replyingToMessage!=null){
      setState(() {
       replyingToMessage=null;
       replyToId=null;
     });
     }
}
Future<void> sendVideo() async {
  final picker = ImagePicker();
  final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

  if (pickedVideo != null) {
    File videoFile = File(pickedVideo.path);

    final storageReference = FirebaseStorage.instance.ref().child('videos/${DateTime.now()}.mp4');
    UploadTask uploadTask = storageReference.putFile(videoFile);
    await uploadTask.whenComplete(() => null);

    String videoUrl = await storageReference.getDownloadURL();
    await chatService.sendMessage(widget.reciverUserID, videoUrl, replyingToMessage, MessageType.video,replyToId);

    try {
      final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
      final token = tokenDoc.data()?['token'];
      await chatService.sendNotification(
        'AAAA3Bg6cyc:APA91bEsBgNbM3DmcopwxkbVpgF3LOGvLXj2rTWP2uegePZCa7pcGnYiQfpSHQ96f3Y6GzAQKrss2UoABLBSY1Iz8LHe-L4mZAt5MJklE-sW5dTnxFAvMIZ351vS9PiDyU6vD5JPGsJA',
        "Sent a video",
        token,
      );
    } catch (e) {
      debugPrint("Notification didn't send");
    }
  }

  if (replyingToMessage != null) {
    setState(() {
      replyingToMessage = null;
      replyToId=null;
    });
  }
}
Future<void> sendFile() async {
  final result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);

    final storageReference = FirebaseStorage.instance.ref().child('files/${DateTime.now()}');
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() => null);

    String fileUrl = await storageReference.getDownloadURL();
    await chatService.sendMessage(widget.reciverUserID, fileUrl, replyingToMessage, MessageType.file,replyToId);

    try {
      final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
      final token = tokenDoc.data()?['token'];
      await chatService.sendNotification(
        'AAAA3Bg6cyc:APA91bEsBgNbM3DmcopwxkbVpgF3LOGvLXj2rTWP2uegePZCa7pcGnYiQfpSHQ96f3Y6GzAQKrss2UoABLBSY1Iz8LHe-L4mZAt5MJklE-sW5dTnxFAvMIZ351vS9PiDyU6vD5JPGsJA',
        "Sent a file",
        token,
      );
    } catch (e) {
      debugPrint("Notification didn't send");
    }
  }

  if (replyingToMessage != null) {
    setState(() {
      replyingToMessage = null;
      replyToId=null;
    });
  }
}
Future<void> deleteImage(String imageUrl) async { 
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
}
Future<void> deleteAudio(String audioUrl) async { 
      await FirebaseStorage.instance.refFromURL(audioUrl).delete();
}
Future<void> deleteFile(String fileUrl) async { 
      await FirebaseStorage.instance.refFromURL(fileUrl).delete();
}
  Future<void> sendMessage() async {
    String message = textEditingController.text; 
    textEditingController.clear();
    if(message.isNotEmpty){
      await chatService.sendMessage(widget.reciverUserID, message,replyingToMessage, MessageType.text, replyToId);
       try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
    final token = tokenDoc.data()?['token'];
      chatService.sendNotification(
       'AAAA3Bg6cyc:APA91bEsBgNbM3DmcopwxkbVpgF3LOGvLXj2rTWP2uegePZCa7pcGnYiQfpSHQ96f3Y6GzAQKrss2UoABLBSY1Iz8LHe-L4mZAt5MJklE-sW5dTnxFAvMIZ351vS9PiDyU6vD5JPGsJA' ,
         message,
          token);
     } catch (e) {
       debugPrint("notification didn't sent");
     }
     if(replyingToMessage!=null){
      setState(() {
       replyingToMessage=null;
       replyToId=null;
     });
     }
    }
  }
  Future<void> removeMessage(String messageId) async {
      await chatService.removeMessage(widget.reciverUserID, firebaseAuth.currentUser!.uid, messageId);
  }
  @override
  void initState(){
    super.initState();
  } 
  @override
  void dispose() {
   controller.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  void _jumpToBottom() {
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }
  Future <void> setLastTimeEntered()async{
await firebaseFirestore.collection("users").doc(widget.reciverUserID).get().then((DocumentSnapshot documentSnapshot) {
  if (documentSnapshot.exists) {
    Timestamp? lastVisited = documentSnapshot.get('lastVisited');
    if (lastVisited != null) {
      // Convert Timestamp to DateTime for better readability
     
      DateTime lastVisitedDateTime = lastVisited.toDate(); 
      // Print the value of lastVisited as a DateTime
      debugPrint('lastVisited: $lastVisitedDateTime');
    } else {
      debugPrint('lastVisited is null');
    }
  } else {
    debugPrint('Document does not exist');  
  }
}).catchError((error) {
  // Handle any errors that occur during the Firestore query
  debugPrint('Error fetching document: $error');
});
}
 
 void recordVoice(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: RecordApp(reciverUserID: widget.reciverUserID, replyingToMessage: replyingToMessage,replyToId:replyToId),
      );
    },
  );
}
String _truncateText(String text, int maxLength) {
    return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
  }
void viewImage(BuildContext context, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(url),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onSurface,)
                ))
            ],
          ),
        ),
      ),
    ),
  );
}
 BuildContext? getContextByKey(ValueKey key) {
    BuildContext? targetContext;
    void visitor(Element element) {
      if (element.widget.key == key) {
        targetContext = element;
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return targetContext;
  }
  void scrollToItem(String itemId) {
   try {
     debugPrint("going to message $itemId");
   } catch (e) {
     debugPrint("didnt go to message $itemId");
   }
      
    
  }
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.reciveruserEmail}', style:const TextStyle(color: Colors.white),),backgroundColor: Theme.of(context).colorScheme.secondary),
      body: Container(
        decoration: settingsService.wallpaperPath!="none"? BoxDecoration(
          image: DecorationImage(fit: BoxFit.cover, image:AssetImage(settingsService.wallpaperPath))
        ):const BoxDecoration(),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList()
              ),
              if (replyingToMessage != null)
            Container(
              padding: EdgeInsets.all(10),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              child: Row(
                children: [
                  Expanded(child: Text("Replying to: $replyingToMessage", overflow: TextOverflow.ellipsis,)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        replyingToMessage = null;
                        replyToId=null;
                      });
                    },
                  )
                ],
              ),
            ),
              _buildMessageInput()
          ],
        ),
      ),
    );
  }
  Widget _buildMessageList(){
    List <String> timestamps=[];
    return StreamBuilder<QuerySnapshot>(
      key: PageStorageKey("_buildMessageList"),
      stream: chatService.getMessages(widget.reciverUserID, firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToEnd();
    // });
    List<QueryDocumentSnapshot> chat =  snapshot.data!.docs.reversed.toList();
        return Stack(
          children: [
            // ListView(
            //   controller: _scrollController,
            //   children: snapshot.data!.docs.map((document) => _buildMessageListItem(document, timestamps)).toList(),
            // ),

            // SingleChildScrollView(
            //   controller: controller,
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: 
            //       snapshot.data!.docs.map((document) => _buildMessageListItem(document, timestamps,)).toList().reversed.toList(),
                
            //   ),
            // ),
       
       FlutterListView(
        reverse: true,
  controller: controller,
  delegate: FlutterListViewDelegate(
    (BuildContext context, int index) => _buildMessageListItem(chat[index], timestamps,index:index),
    childCount: snapshot.data!.docs.length,
  )),

         //   if (_scrollController.offset >= _scrollController.position.maxScrollExtent)
        //     Positioned(
        //       right: 30,
        //       bottom: 30,
        //       child: FloatingActionButton(
        //         onPressed: _scrollToEnd,
        //         child: const Icon(Icons.arrow_downward),
        //       ),
        //     ),
           ],
         );
        }
      
    },);
  }
   Widget _buildMessageListItem(DocumentSnapshot documentSnapshot, List timestamps, {int? index}){
 Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
var aligment = (data['senderId']==firebaseAuth.currentUser!.uid)?Alignment.centerRight:Alignment.centerLeft;
final Timestamp time = data['timestamp'];
return Column(
  key: ValueKey(documentSnapshot.id),
  children: [
     Visibility(
  visible: timestamps.contains(time.toDate().toString().substring(0, 10)) ? false : () {
    timestamps.add(time.toDate().toString().substring(0, 10));
    return true;
  }(),
  child: Text(
            time.toDate().toString().substring(0, 10),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
),
Container(
  alignment: aligment,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: (aligment!=Alignment.centerRight)? CrossAxisAlignment.start:CrossAxisAlignment.end,
      children: [
      if(kDebugMode) Text("${ValueKey(documentSnapshot.id).value} ${index??''}"),
      GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // Detected a right swipe
                        setState(() {
                          replyingToMessage = data['message'];
                          replyToId=documentSnapshot.id;
                        });
                      }
                    },
        child: 
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:aligment==Alignment.centerRight? CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: [
            if(data['replyTo']!=null) 
              data['replyTo']!.contains("%!image!_")||data['replyTo']!.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/images")?
              GestureDetector(
                onDoubleTap: (){
                  data['replyToId']==null?
                  viewImage(context,data['replyTo']!.contains("%!image!_")?data['replyTo']!.substring(9):data['replyTo']!)
                  : WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToItem(data['replyToId']);
    }); 
                },
                onTap: (){
                  data['replyToId']==null?
                  viewImage(context,data['replyTo']!.contains("%!image!_")?data['replyTo']!.substring(9):data['replyTo']!)
                  :WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToItem(data['replyToId']);
    }); 
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("replyed:", style: TextStyle(fontSize: 10,)),
                     Icon(Icons.image, size: IconTheme.of(context).size!*0.7,),
                  ],
                ),
              ) 
              :
              data['replyTo']!.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/audio")?
              Text("replyed: audio")
              :
             data['replyTo']!.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/videos")?
             Text("replyed: video")
              :
              data['messageType']==MessageType.audio?
              Text("replyed: audio")
              :
              GestureDetector(
               onDoubleTap: () {
                data['replyToId']==null?
                  InAppNotification.show(
                child: NotificationBody(child: Text("reply to: ${data['replyTo']!}", maxLines: 5,),),
              context: context,
              onTap: () => (){},
                )
                  :WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToItem(data['replyToId']);
    }); 
               },
               onTap:(){
                 data['replyToId']==null?
                  InAppNotification.show(
                child: NotificationBody(child: Text("reply to: ${data['replyTo']!}", maxLines: 5,),),
              context: context,
              onTap: () => (){},
                )
                 : WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToItem(data['replyToId']);
    }); 
               } ,
                child: RichText(text: TextSpan(
                  children: [
                   TextSpan(text: "replyed:", style: TextStyle(fontSize: 12)),
                   TextSpan(text: _truncateText(data['replyTo']!, 8), style: TextStyle(fontSize: 15,))
                  ]
                )),
              ),
       data['messageType']!=null?
       MessageBox(
        replyToId: data['replyToId'],
        messageType: defineType(data['messageType']),
        replyTo: data['replyTo'],
        timestamp: time.toDate().toString().substring(11, 16), 
        aligment: aligment,
        child:
        defineType(data['messageType'])==MessageType.audio?
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ChatAudioPlayer(source:AudioSource.uri(Uri.parse(data['message'])),),
          if(aligment==Alignment.centerRight)  IconButton(onPressed: (){deleteAudio(data['message']);
            removeMessage(documentSnapshot.id);}, icon: Icon(Icons.delete)),
          ],
        )
        :
        defineType(data['messageType'])==MessageType.file?
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(onPressed: (){deleteFile(data['message']).whenComplete(()=>settingsService.showFloatingMessage(context, "sucessifully deleted")); removeMessage(documentSnapshot.id);}, icon: Icon(Icons.delete)),
            FileView(fileUrl:data['message']),
          ],
        )
        :
        defineType(data['messageType'])==MessageType.video?
        VideoView(videoUrl: data['message'],)
        :
        CupertinoContextMenu(
        //   previewBuilder: (BuildContext context, animation, child) {
        //     final MessageType messageType = defineType(data['messageType']);
        //     switch (messageType) {
        //       case MessageType.file:
        //         return Scaffold(
        //           backgroundColor: Colors.transparent,
        //           body: Center(
        //             child: Text("file"),
        //           ),
        //         );
        //       case MessageType.audio:
        //         return Scaffold(
        //           backgroundColor: Colors.transparent,
        //           body: Center(
        //             child: Text("Audio"),
        //           ),
        //         );
        //       case MessageType.video:
        //         return Scaffold(
        //           backgroundColor: Colors.transparent,
        //           body: Center(
        //             child: Text("video"),
        //           ),
        //         );
        //       case MessageType.text:
        //         return Scaffold(
        //           backgroundColor: Colors.transparent,
        //           body: Center(child: SelectableText(data['message'],style: const TextStyle(fontSize: 30),
        //               maxLines: 4,)),
        //         );
        //       case MessageType.image:
        //         return Scaffold(
        //           backgroundColor: Colors.transparent,
        //           body: Center(
        //             child: CachedNetworkImage(
        //  fit: BoxFit.contain,
        //  imageUrl: data['message'],
        //  progressIndicatorBuilder: (context, url, downloadProgress) => 
        //          CircularProgressIndicator(value: downloadProgress.progress),
        //  errorWidget: (context, url, error) => const Icon(Icons.error),
        //   )),
        //         );  
        //       default:
        //          return Scaffold(
        //           body: Center(child: Text("undefined")),
        //          );
        //     }     
        //   },
        actions: [
          CupertinoContextMenuAction(child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("Copy"),
              Icon(Icons.copy_outlined),
            ],
          ),
           
          onPressed: (){     
               Clipboard.setData(ClipboardData(text:data['message'].toString()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
            ),
          );
            debugPrint("Shoud Copy");
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ),
         aligment==Alignment.centerRight? CupertinoContextMenuAction(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("Delete"),
              Icon(Icons.delete_outlined),
            ],
          ),
          onPressed: (){
            final MessageType messageType = defineType(data['messageType']);
            switch (messageType) {
              case MessageType.text:
                break;
              case MessageType.file:
              break;
              case MessageType.image:  
               deleteImage(data['message'].toString());
               break;
              case MessageType.video:
              break;
              default:
              break;
            }
            removeMessage(documentSnapshot.id);
            debugPrint(documentSnapshot.id.toString());
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ):const SizedBox(),
         defineType(data['messageType'])==MessageType.image? CupertinoContextMenuAction(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("Download"),
              Icon(Icons.download),
            ],
          ),
          onPressed: (){
            launch(data['message']);
            debugPrint(documentSnapshot.id.toString());
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ):const SizedBox(),
          kDebugMode? CupertinoContextMenuAction(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("get Id"),
              Icon(Icons.copy_all),
            ],
          ),
          onPressed: (){
            debugPrint(documentSnapshot.id.toString());
             Clipboard.setData(ClipboardData(text:documentSnapshot.id.toString()));
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ):const SizedBox()
        ],
        child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width*0.7,
        ),
        child:
        defineType(data['messageType'])==MessageType.image?
        InstaImageViewer(
          child: InteractiveViewer(
        child: CachedNetworkImage(
          fit: BoxFit.contain,
             imageUrl: data['message'],
             progressIndicatorBuilder: (context, url, downloadProgress) => 
                     CircularProgressIndicator(value: downloadProgress.progress),
             errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          ),
        )
        :
         Text(
          data['message'],
        )
      )
      )
        )
       : 
        MessageBox(
          replyToId: data['replyToId'],
          aligment: aligment,
          replyTo: data['replyTo'],
          timestamp: time.toDate().toString().substring(11, 16),
          child:
        CupertinoContextMenu(
      //     previewBuilder: (BuildContext context, animation, child) {
      //       return Scaffold(backgroundColor: Colors.transparent, body: Center(child:
      //       data['message'].toString().contains("%!image!_")?
      //  // Image.network(data['message'].toString().substring(9), fit: BoxFit.contain, scale: 0.5,)
      //  CachedNetworkImage(
      //    fit: BoxFit.contain,
      //    imageUrl: data['message'].toString().substring(9),
      //    progressIndicatorBuilder: (context, url, downloadProgress) => 
      //            CircularProgressIndicator(value: downloadProgress.progress),
      //    errorWidget: (context, url, error) => const Icon(Icons.error),
      //     )
      //   :
      //    SelectableText(data['message'],style: const TextStyle(fontSize: 30),
      //                 maxLines: 4,)));
           
      //     },
        actions: [
          CupertinoContextMenuAction(child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("Copy"),
              Icon(Icons.copy_outlined),
            ],
          ),
           
          onPressed: (){
             Clipboard.setData(ClipboardData(text: data['message'].toString().contains("%!image!_")?data['message'].toString().substring(9):data['message']));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
            ),
          );
            debugPrint("Shoud Copy");
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ),
         aligment==Alignment.centerRight? CupertinoContextMenuAction(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("Delete"),
              Icon(Icons.delete_outlined),
            ],
          ),
          onPressed: (){
            if(data['message'].toString().contains("%!image!_")){
              deleteImage(data['message'].toString().substring(9));
            }
            removeMessage(documentSnapshot.id);
            debugPrint(documentSnapshot.id.toString());
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ):const SizedBox(),
         data['message'].toString().contains("%!image!_")? CupertinoContextMenuAction(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
            children: const[
              Text("Download"),
              Icon(Icons.download),
            ],
          ),
          onPressed: (){
            launch(data['message'].toString().substring(9));
            debugPrint(documentSnapshot.id.toString());
            Navigator.of(context, rootNavigator: true).pop(); 
          },
          ):const SizedBox()
        ],
        child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width*0.7,
        ),
        child:
        data['message'].toString().contains("%!image!_")?
        InstaImageViewer(
          child: InteractiveViewer(
        child: CachedNetworkImage(
          fit: BoxFit.contain,
             imageUrl: data['message'].toString().substring(9),
             progressIndicatorBuilder: (context, url, downloadProgress) => 
                     CircularProgressIndicator(value: downloadProgress.progress),
             errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          ),
        )
        :
         Text(
          data['message'],
        ),
      )
      ),),],
        ),
      ),
      ],  
    ),
  ),
)
  ],
);


  }
  Widget _buildMessageInput(){
    return Row(
      children: [
        // IconButton(onPressed: (){
        //  if(textEditingController.text.startsWith("u^ ")&&textEditingController.text.endsWith(" ^u")){
        //   textEditingController.text = textEditingController.text.substring(3,textEditingController.text.length-3);
        //  }
        //  else{ 
        //   String text = textEditingController.text;
        //   text= "u^ $text ^u";
        //     textEditingController.text = text;
        //   }
        // }, icon: const Icon(Icons.text_fields_outlined)),
         IconButton(onPressed: (){
          recordVoice(context);
         },icon: Icon(Icons.multitrack_audio_rounded, color:Theme.of(context).primaryColor),),
        Expanded(
          child: TextField(
            style: TextStyle(color: Theme.of(context).primaryColor,),
  //         keyboardType: TextInputType.multiline,
  // maxLines: null,
  // minLines: null,
  // textInputAction: TextInputAction.newline,
          focusNode: FocusNode(skipTraversal: true),
          controller: textEditingController,
          onSubmitted: (value) {
            // ignore: unnecessary_null_comparison
            if (value.isNotEmpty||value!=null) {
              sendMessage();
              }
          },
          decoration: InputDecoration(
            hintText: "Send a message...",
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor,)
            )
          ),
          )),
          SpeedDial(
            backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        animationDuration: Duration(milliseconds: 500),
        icon: Icons.link,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: Icon(Icons.file_present_rounded, color: Theme.of(context).primaryColor),
            label: "Send a File",
            onTap: () {
              sendFile();
              debugPrint("File linking");
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add_photo_alternate, color: Theme.of(context).primaryColor),
            label: "Send an Image",
            onTap: () {
              sendImage();
              debugPrint("Image linking");
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.audio_file_rounded, color: Theme.of(context).primaryColor),
            label: "Send an Audio",
            onTap: () {
              debugPrint("Audio linking");
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.video_file_rounded, color: Theme.of(context).primaryColor,),
            label: "Send a video",
            onTap: () {
              sendVideo();
              debugPrint("sending a video");
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.add_link_rounded, color: Theme.of(context).primaryColor,),
            label: "Send a link",
            onTap: () {
              debugPrint("sending a link");
            },
          )
        ],
          ),
        GestureDetector(
          onTap: (){
            sendMessage();
          },
          onDoubleTap: (){
            sendMessage();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon( Icons.send, color: Theme.of(context).primaryColor,),
          ),
        ),
      ],
    );
  }
}
