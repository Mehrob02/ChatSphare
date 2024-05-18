// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/message_box.dart';
import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.reciveruserEmail, required this.reciverUserID});
  final String reciveruserEmail;
  final String reciverUserID;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Timestamp? _lastVisited;
  List <String> timestamps=[];
  final TextEditingController textEditingController = TextEditingController();
  final ChatService chatService =ChatService();
  final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;

   Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery); 

    if (pickedImage != null) {
     
      File imageFile = File(pickedImage.path);
      
      final storageReference = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);

      String imageUrl = await storageReference.getDownloadURL();
      imageUrl="%!image!_$imageUrl";
      await chatService.sendMessage(widget.reciverUserID, imageUrl);
    }
}
Future<void> deleteImage(String imageUrl) async { 
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
}
  Future<void> sendMessage() async {
    if(textEditingController.text.isNotEmpty){
      await chatService.sendMessage(widget.reciverUserID, textEditingController.text);
       try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
    final token = tokenDoc.data()?['token'];
      chatService.sendNotification(
       'AAAA3Bg6cyc:APA91bEsBgNbM3DmcopwxkbVpgF3LOGvLXj2rTWP2uegePZCa7pcGnYiQfpSHQ96f3Y6GzAQKrss2UoABLBSY1Iz8LHe-L4mZAt5MJklE-sW5dTnxFAvMIZ351vS9PiDyU6vD5JPGsJA' ,
         textEditingController.text,
          token);
     } catch (e) {
       debugPrint("notification didn't sent");
     }
      textEditingController.clear();
    }
  }
  Future<void> removeMessage(String messageId) async {
      await chatService.removeMessage(widget.reciverUserID, firebaseAuth.currentUser!.uid, messageId);
  }
  @override
  void initState(){
    super.initState();
  }
  Future <void> setLastTimeEntered()async{
await firebaseFirestore.collection("users").doc(widget.reciverUserID).get().then((DocumentSnapshot documentSnapshot) {
  if (documentSnapshot.exists) {
    Timestamp? lastVisited = documentSnapshot.get('lastVisited');
    if (lastVisited != null) {
      // Convert Timestamp to DateTime for better readability
     
      DateTime lastVisitedDateTime = lastVisited.toDate(); 
      setState(() {
        _lastVisited = lastVisited;
      });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.reciveruserEmail}')),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList()
            ),
            _buildMessageInput()
        ],
      ),
    );
  }
  Widget _buildMessageList(){
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getMessages(widget.reciverUserID, firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
      if(snapshot.hasError){
        return const Text("Something went wrong");
      }
      if(snapshot.connectionState==ConnectionState.waiting){
        return const Center(child: CircularProgressIndicator());
      }
      else{
        return ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageListItem(document)).toList(),
        );
      }
    },);
  }
   Widget _buildMessageListItem(DocumentSnapshot documentSnapshot){
 Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
var aligment = (data['senderId']==firebaseAuth.currentUser!.uid)?Alignment.centerRight:Alignment.centerLeft;
final Timestamp time = data['timestamp'];
return Column(
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
      Text(
                time.toDate().toString().substring(11, 16),
                style: const TextStyle(color: Colors.grey),
              ),
      MessageBox(child: 
      CupertinoContextMenu(
        previewBuilder: (context, animation, child) {
          return Scaffold(backgroundColor: Colors.transparent, body: Center(child:
          data['message'].toString().contains("%!image!_")?
 // Image.network(data['message'].toString().substring(9), fit: BoxFit.contain, scale: 0.5,)
 CachedNetworkImage(
       fit: BoxFit.contain,
       imageUrl: data['message'].toString().substring(9),
       progressIndicatorBuilder: (context, url, downloadProgress) => 
               CircularProgressIndicator(value: downloadProgress.progress),
       errorWidget: (context, url, error) => const Icon(Icons.error),
    )
  :
   Text(data['message'],style: const TextStyle(fontSize: 30),overflow: TextOverflow.ellipsis,
                    maxLines: 4,)));
         
        },
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
          Navigator.of(context).pop();
        },
        ),
        CupertinoContextMenuAction(child: Row(
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
          Navigator.of(context).pop();
        },
        ),
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
          Navigator.of(context).pop();
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
    style: const TextStyle(color: Colors.white),
  ),
)
),),
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
        Expanded(child: TextField(
          focusNode: FocusNode(skipTraversal: true),
          controller: textEditingController,
          decoration: InputDecoration(
            hintText: "Send a message...",
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor,)
            )
          ),
          )),
          GestureDetector(
          onTap: (){
            sendImage();
          },
          onDoubleTap: (){
            sendImage();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon( Icons.image, color: Theme.of(context).primaryColor,),
          ),
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