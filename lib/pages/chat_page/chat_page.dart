// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables, unused_import, use_build_context_synchronously, non_constant_identifier_names, unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/pages/chat_page/widgets/chat_audio_player.dart';
import 'package:chatsphere/pages/chat_page/widgets/message_box.dart';
import 'package:chatsphere/models/message.dart';
import 'package:chatsphere/mytests/testfile2.dart';
import 'package:chatsphere/pages/chat_page/widgets/record.dart';
import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:chatsphere/pages/chat_page/widgets/video_view.dart';
import 'package:chatsphere/variables.dart';
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
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/file_view.dart';
import '../../widgets/notification_body.dart';
import '../../services/settings/settings_service.dart';
import 'widgets/profile_view.dart';
import 'widgets/search_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.reciverUserEmail, required this.reciverUserID, required this.reciverUserName, this.profileImageUrl, this.about});
  final String reciverUserEmail;
  final String reciverUserID;
  final String reciverUserName;
  final String? profileImageUrl;
  final String? about;
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
  final PageController pageController = PageController();
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
 
  double _uploadProgress = 0;
  final int maxFileSize = 150 * 1024 * 1024; // 150 MB

  Future<void> sendImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: imageSource);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      final storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });

      await uploadTask.whenComplete(() => setState(() {
        _uploadProgress = 0;
      }));
      String imageUrl = await storageReference.getDownloadURL();
      await chatService.sendMessage(widget.reciverUserID, imageUrl, replyingToMessage, MessageType.image, replyToId);

      try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
        final token = tokenDoc.data()?['token'];
        chatService.sendNotification(serverKey, "Sent an image", token);
      } catch (e) {
        debugPrint("Notification didn't send");
      }

      if (replyingToMessage != null) {
        setState(() {
          replyingToMessage = null;
          replyToId = null;
        });
      }
    }
  }
Future<void> selectSource()async{
ImageSource? imageSource = 
await showDialog(
  context: context, 
builder:(context) {
  return SimpleDialog(
    title: Text("Select Image Source"),
    children: <Widget>[
      SimpleDialogOption(
        child: Text("Camera"),
        onPressed: () {
          Navigator.pop(context, ImageSource.camera);
        }
        ),
        SimpleDialogOption(
          child: Text("Gallery"),
          onPressed: () {
            Navigator.pop(context, ImageSource.gallery);
            }
            ),
            ],
            );
},);
if (imageSource != null) {
sendImage(imageSource);
}
}
  Future<void> sendVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      File videoFile = File(pickedVideo.path);
      final storageReference = FirebaseStorage.instance.ref().child('videos/${DateTime.now()}.mp4');
      UploadTask uploadTask = storageReference.putFile(videoFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });

      await uploadTask.whenComplete(() => setState(() {
        _uploadProgress = 0;
      }));
      String videoUrl = await storageReference.getDownloadURL();
      await chatService.sendMessage(widget.reciverUserID, videoUrl, replyingToMessage, MessageType.video, replyToId);

      try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
        final token = tokenDoc.data()?['token'];
        chatService.sendNotification(serverKey, "Sent a video", token);
      } catch (e) {
        debugPrint("Notification didn't send");
      }

      if (replyingToMessage != null) {
        setState(() {
          replyingToMessage = null;
          replyToId = null;
        });
      }
    }
  }

  Future<void> sendFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      int fileSize = await file.length();

      if (fileSize > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File size exceeds 150 MB. Please select a smaller file.'),
          ),
        );
        return;
      }

      String fileName = result.files.single.name; // Получаем только имя файла
      final storageReference = FirebaseStorage.instance.ref().child('files/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });

      await uploadTask.whenComplete(() => setState(() {
        _uploadProgress = 0;
      }));

      String fileUrl = await storageReference.getDownloadURL();
      await chatService.sendMessage(widget.reciverUserID, fileUrl, replyingToMessage, MessageType.file, replyToId, fileName: fileName);

      try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
        final token = tokenDoc.data()?['token'];
        chatService.sendNotification(serverKey, "Sent a file", token);
      } catch (e) {
        debugPrint("Notification didn't send");
      }

      if (replyingToMessage != null) {
        setState(() {
          replyingToMessage = null;
          replyToId = null;
        });
      }
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
       serverKey ,
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
  //  controller.addListener(_scrollListener);
    super.initState();
  } 
  @override
  void dispose() {
   //  controller.removeListener(_scrollListener);
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
  Future<String> _getProfileImageUrl(String recieverId) async {
    try {
      final ref = FirebaseStorage.instance.ref('user_profile_images/$recieverId.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // Если изображение не найдено или произошла ошибка, возвращаем URL изображения по умолчанию
      return "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png";
    }
  }
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    return PageView(
      controller: pageController,
      physics:NeverScrollableScrollPhysics(),
      children: [
       // SearchMessage(),
        Scaffold(
         // backgroundColor: Colors.indigo,
          appBar: AppBar(
            titleSpacing: 0.0,
            title: GestureDetector(
              onTap: () {
                debugPrint("Show Profile");
                pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);
              },
              onDoubleTap: () {
                debugPrint("Show Profile");
                pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<String>(
                      future: _getProfileImageUrl(widget.reciverUserID),
                      builder: (context, snapshot) {
                  if (snapshot.hasData&&!kIsWeb) {
                     String profileImageUrl = snapshot.data!;
                  return CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(profileImageUrl),
                  );
                  }else{return CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
                    );
                 }
                      },
                    ),
                   
                  SizedBox(width: 4,),
                  Text(widget.reciverUserName, style:const TextStyle(color: Colors.white),),
                ],
              ),
            ),
            // actions: [
            //   IconButton(onPressed: ()=>pageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut), icon: Icon(Icons.search_rounded))
            // ],
           backgroundColor: Theme.of(context).colorScheme.onBackground
           ),
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
                if (_uploadProgress > 0)
                  Text("Upload Progress: ${_uploadProgress.toStringAsFixed(2)}%", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 28),),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    child: _buildMessageInputNew(),
                  )
              ],
            ),
          ),
        ),
        ProfileView(profileId: widget.reciverUserID, name: widget.reciverUserName, email: widget.reciverUserEmail, about: widget.about, goBack: () { pageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);},)
      ],
    );
  }
  Widget _buildMessageList(){
    List <String> timestamps=[];
    return StreamBuilder<QuerySnapshot>(
      key: PageStorageKey("_buildMessageList"),
      stream: chatService.getMessages(widget.reciverUserID, firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
     try {
       switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
    List<QueryDocumentSnapshot> chat =  snapshot.data!.docs.reversed.toList();
        return Stack(
          children: [   
       FlutterListView(
        reverse: true,
  controller: controller,
  delegate: FlutterListViewDelegate(
    (BuildContext context, int index) => _buildMessageListItem(chat[index], timestamps,index:index),
    childCount: snapshot.data!.docs.length,
  )),

           if (_scrollController.hasClients &&(controller.offset >= controller.position.maxScrollExtent))
            Positioned(
              right: 30,
              bottom: 30,
              child: FloatingActionButton(
                onPressed: _scrollToEnd,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
           ],
         );
        }
     } catch (e) {
      debugPrint(e.toString());
       return Text("Databse is in hight demand try to log in tomorrow");
     }
        
      
    },);
  }
  void markAllMessagesAsRead(String chatId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });
  }
   Widget _buildMessageListItem(DocumentSnapshot documentSnapshot, List timestamps, {int? index}){
 Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
var aligment = (data['senderId']==firebaseAuth.currentUser!.uid)?Alignment.centerRight:Alignment.centerLeft;
if (aligment == Alignment.centerLeft  &&data['isRead']!=null && !data['isRead']) {
  List <String> ids =[widget.reciverUserID, firebaseAuth.currentUser!.uid];
    ids.sort();
    String chatRoomId = ids.join("_");
      // Update Firestore document to mark the message as read
      FirebaseFirestore.instance
          .collection('chat_rooms').doc(chatRoomId).collection("messages")
          .doc(documentSnapshot.id)
          .update({'isRead': true});
    }
final Timestamp time = data['timestamp'];
String message = data['message']??"";
MessageType? messageType =data['messageType']!=null?defineType(data['messageType']):null;
String? replyTo=data['replyTo'];
return Column(
  key: ValueKey(documentSnapshot.id),
  children: [
//      Visibility(
//   visible: timestamps.contains(time.toDate().toString().substring(0, 10)) ? false : () {
//     timestamps.add(time.toDate().toString().substring(0, 10));
//     return true;
//   }(),
//   child: Text(
//             time.toDate().toString().substring(0, 10),
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
// ),
Container(
  alignment: aligment,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Column(
      crossAxisAlignment: (aligment!=Alignment.centerRight)? CrossAxisAlignment.start:CrossAxisAlignment.end,
      children: [
  //    if(kDebugMode) Text("${ValueKey(documentSnapshot.id).value} ${index??''}"),
      GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // Detected a right swipe
                        setState(() {
                          replyingToMessage = message;
                          replyToId=documentSnapshot.id;
                        });
                      }
                    },
                    onHorizontalDragStart: (details) {
                        // Detected a left swipe
                        setState(() {
                          replyingToMessage = message;
                          replyToId=documentSnapshot.id;
                        });
                    },
        child: 
        Container(
          decoration: BoxDecoration(
           color:aligment==Alignment.centerRight? Theme.of(context).primaryColor.withOpacity(0.3):Theme.of(context).colorScheme.onSecondary.withOpacity(0.3), 
           borderRadius:aligment==Alignment.centerRight? BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10), bottomRight: Radius.circular(13)):BorderRadius.only( topRight: Radius.circular(10), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(10),),

          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:aligment==Alignment.centerRight? CrossAxisAlignment.end:CrossAxisAlignment.start,
            children: [
              if(replyTo!=null) 
                replyTo.contains("%!image!_")||replyTo.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/images")?
                GestureDetector(
                  onDoubleTap: (){
                    data['replyToId']==null?
                    viewImage(context,replyTo.contains("%!image!_")?replyTo.substring(9):replyTo)
                    : WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollToItem(data['replyToId']);
              }); 
                  },
                  onTap: (){
                    data['replyToId']==null?
                    viewImage(context,replyTo.contains("%!image!_")?replyTo.substring(9):replyTo)
                    :WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollToItem(data['replyToId']);
              }); 
                  },
                  child: Icon(Icons.image, size: IconTheme.of(context).size!*0.7,),
                ) 
                :
                replyTo.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/audio")?
                Text(" ${data['replySenderId']!=null?(data['replySenderId']!=FirebaseAuth.instance.currentUser!.uid? "${widget.reciverUserName}\n":"You\n"):""}audio")
                :
               replyTo.contains("https://firebasestorage.googleapis.com/v0/b/chatsphere-bbc53.appspot.com/o/videos")?
               Text(" ${data['replySenderId']!=null?(data['replySenderId']!=FirebaseAuth.instance.currentUser!.uid? "${widget.reciverUserName}\n":"You\n"):""}video")
                :
                GestureDetector(
                 onDoubleTap: () {
                  //data['replyToId']==null?
                    InAppNotification.show(
                  child: NotificationBody(child: Text(replyTo, maxLines: 5,),),
                context: context,
                onTap: () => (){},
                  )
              //               :WidgetsBinding.instance.addPostFrameCallback((_) {
              //   scrollToItem(data['replyToId']);
              // })
              ; 
                 },
                 onTap:(){
                 //  data['replyToId']==null?
                    InAppNotification.show(
                  child: NotificationBody(child: Text(replyTo, maxLines: 5,),),
                context: context,
                onTap: () => (){},
                  )
              //              : WidgetsBinding.instance.addPostFrameCallback((_) {
              //   scrollToItem(data['replyToId']);
              // })
              ; 
                 } ,
                  child: Text(_truncateText(" ${data['replySenderId']!=null?(data['replySenderId']!=FirebaseAuth.instance.currentUser!.uid? "${widget.reciverUserName}\n":"You\n"):""} $replyTo", 30), style: TextStyle(fontSize: 15,))
                ),
                 messageType!=null?
                 MessageBox(
                  isRead: data['isRead'],
          replyToId: data['replyToId'],
          messageType: messageType,
          replyTo: replyTo,
          timestamp: time.toDate().toString().substring(11, 16), 
          aligment: aligment,
          child:
          messageType==MessageType.audio?
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ChatAudioPlayer(source:AudioSource.uri(Uri.parse(message)),),
            if(aligment==Alignment.centerRight)  IconButton(onPressed: (){deleteAudio(message);
              removeMessage(documentSnapshot.id);}, icon: Icon(Icons.delete)),
            ],
          )
          :
          messageType==MessageType.file?
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             if(aligment== Alignment.centerRight) IconButton(onPressed: (){deleteFile(message).whenComplete(()=>settingsService.showFloatingMessage(context, "sucessifully deleted")); removeMessage(documentSnapshot.id);}, icon: Icon(Icons.delete)),
              FileView(fileUrl:message,fileName: data['fileName'],),
            ],
          )
          :
          messageType==MessageType.video?
          VideoView(videoUrl: message,)
          :
          CupertinoContextMenu(
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
                 Clipboard.setData(ClipboardData(text:message.toString()));
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
              final MessageType message_type = messageType;
              switch (message_type) {
                case MessageType.text:
                  break;
                case MessageType.file:
                break;
                case MessageType.image:  
                 deleteImage(message.toString());
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
           messageType==MessageType.image? CupertinoContextMenuAction(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.center,
              children: const[
                Text("Download"),
                Icon(Icons.download),
              ],
            ),
            onPressed: (){
              launch(message);
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
          messageType==MessageType.image?
          InstaImageViewer(
            child: InteractiveViewer(
          child: CachedNetworkImage(
            fit: BoxFit.contain,
               imageUrl: message,
               progressIndicatorBuilder: (context, url, downloadProgress) => 
                       CircularProgressIndicator(value: downloadProgress.progress),
               errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            ),
          )
          :
           Text(
            message,
          )
                )
                )
          )
                 : 
          MessageBox(
            isRead: data['isRead'],
            replyToId: data['replyToId'],
            aligment: aligment,
            replyTo: replyTo,
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
               Clipboard.setData(ClipboardData(text: message.toString().contains("%!image!_")?message.toString().substring(9):message));
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
              if(message.toString().contains("%!image!_")){
                deleteImage(message.toString().substring(9));
              }
              removeMessage(documentSnapshot.id);
              debugPrint(documentSnapshot.id.toString());
              Navigator.of(context, rootNavigator: true).pop(); 
            },
            ):const SizedBox(),
           message.toString().contains("%!image!_")? CupertinoContextMenuAction(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.center,
              children: const[
                Text("Download"),
                Icon(Icons.download),
              ],
            ),
            onPressed: (){
              launch(message.toString().substring(9));
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
          message.toString().contains("%!image!_")?
          InstaImageViewer(
            child: InteractiveViewer(
          child: CachedNetworkImage(
            fit: BoxFit.contain,
               imageUrl: message.toString().substring(9),
               progressIndicatorBuilder: (context, url, downloadProgress) => 
                       CircularProgressIndicator(value: downloadProgress.progress),
               errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            ),
          )
          :
           Text(
            message,
          ),
                )
                ),),],
          ),
        ),
      ),
      ],  
    ),
  ),
)
  ],
);


  }
  Widget _buildMessageInputNew(){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3)
          )
        ]
      ),
      child: Row(
        children: [
          IconButton(onPressed: (){
          recordVoice(context);
         },icon: Icon(Icons.multitrack_audio_rounded, color:Theme.of(context).primaryColor),),
          Expanded(
            child: TextField(
              controller: textEditingController,
              style: Theme.of(context).textTheme.titleSmall,
              focusNode: FocusNode(skipTraversal: true),
              onSubmitted: (value) {
                sendMessage();
              },
              decoration: InputDecoration(
                hintText: 'Write your message',
                hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.grey[700]
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 18)
              ),
            ),
          ),
          SizedBox(width: 8,),
          SpeedDial(
            backgroundColor: Theme.of(context).colorScheme.onBackground,
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
              selectSource();
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
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: GestureDetector(
              child: IconButton(onPressed: (){sendMessage();}, icon: Icon(Icons.send_rounded,  color: Theme.of(context).primaryColor,)),
             
            ),
          )
        ],
      ),
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
              selectSource();
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
