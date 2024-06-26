// ignore_for_file: unused_local_variable, body_might_complete_normally_nullable, unused_import, unused_field, prefer_const_constructors, unused_element, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/pages/home_page/pages/friend_request_page.dart';
import 'package:chatsphere/models/message.dart';
import 'package:chatsphere/widgets/notification_body.dart';
import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:chatsphere/services/settings/settings_service.dart';
import 'package:chatsphere/pages/settings_page/pages/settings_page.dart';
import 'package:chatsphere/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floating_menu_panel/floating_menu_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'as math;

import '../../chat_page/chat_page.dart';
import '../../../services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth =FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ChatService chatService =ChatService();
  List <IconData> icons=[
  Icons.circle,
  Icons.circle,
  Icons.circle,
  Icons.circle,
];
List<MaterialColor> appColors=[
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.deepPurple,
];
List<dynamic> myContacts=[];
//  final textController=TextEditingController();

@override
  void initState() {
    setLastTimeEntered();
   Timer.periodic(const Duration(seconds: 60), (timer) {
    setLastTimeEntered();
  });
  loadContacts();
    super.initState();
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
  Future<void> loadContacts() async {
  try {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
      .doc("my_contacts")
      .get();

  if (docSnapshot.exists) {
   myContacts = docSnapshot['contacts'];
    // Теперь myContacts содержит ваш список контактов.
    debugPrint(myContacts.toString());
  } else {
    try {
      await firebaseFirestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("${FirebaseAuth.instance.currentUser!.uid}_contacts").doc("my_contacts").set({
        "contacts": []
      });
    } catch (e) {
      debugPrint("token erroryyyy");
    }
    debugPrint('Document does not exist');
  }
  } catch (e) {
    debugPrint("$e");
  }
}

void addContactGetId()async{
   String newContact = ''; // Инициализация пустой строкой
  String? result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter contacts id'),
        content: TextField(
          onChanged: (value) {
            newContact = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(newContact);
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // Возвращаем null при отмене
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );

  if (result != null && result.isNotEmpty) {
   // addContact(result);
   sendRequest(result);
    if (kDebugMode) {
      print('New contact: $result');
    }
  }

}
Future<void> sendRequest(String newContactId) async {
 try {
      final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(newContactId).get();
      final token = tokenDoc.data()?['token'];
      await chatService.sendNotification(
        serverKey,
        "Sent a chat request",
        token,
      );
      if(!myContacts.contains(newContactId)){
        addRequest(newContactId);
      InAppNotification.show(
                child: NotificationBody(child: Text("send reqest to: $newContactId${kDebugMode? "\n $token":""}",),),
              context: context,
              onTap: () => (){},
                );
      }
      
    } catch (e) {
      debugPrint("Notification didn't send");
    }
   
}

Future<void> addRequest(String newContactId) async {
  try {
    // Проверка, существует ли пользователь с таким ID
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(newContactId)
        .get();
    if (!userDocSnapshot.exists) {
      debugPrint("User does not exist");
      return;
    }
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(newContactId)
        .collection("${newContactId}_contacts")
        .doc("my_requests")
        .get();

    if (docSnapshot.exists) {
      List<dynamic> myRequests = docSnapshot['requests'];
      debugPrint("$myRequests");
      // Проверка, что контакта еще нет в списке
      if (!myRequests.contains(FirebaseAuth.instance.currentUser!.uid)) {
        myRequests.add(FirebaseAuth.instance.currentUser!.uid);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newContactId)
            .collection("${newContactId}_contacts")
            .doc("my_requests")
            .set({'requests': myRequests});
        debugPrint("Contact added successfully");
      } else {
        debugPrint("You already have this contact");
      }
    } else {
      // Если документа не существует, создаем новый со списком контактов
     await firebaseFirestore
            .collection('users')
            .doc(newContactId)
            .collection("${newContactId}_contacts")
            .doc("my_requests")
            .set({"requests": [FirebaseAuth.instance.currentUser!.uid]});
      debugPrint("Contact added successfully");
    }
  } catch (e) {
    debugPrint("Error adding contact: $e");
  }
}

  Future<void> setLastTimeEntered()async{
    try {
      await firebaseFirestore.collection("users").doc(auth.currentUser!.uid).set({
      "email" :auth.currentUser!.email,
      "uid": auth.currentUser!.uid,
      "lastVisited":Timestamp.now(),
    });
    } catch (e) {
      debugPrint("ooops");
    }

  }
Future<String> getNickNames(DocumentSnapshot documentSnapshot)async{
DocumentSnapshot nickNameSnapshot =await firebaseFirestore.collection("nickNames").doc(documentSnapshot.id).get();
Map<String, dynamic> nickNamesData = nickNameSnapshot.data() as Map<String, dynamic>;
String nickName = nickNamesData['nickName'];
return nickName;
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
  void dispose() {
    super.dispose();
  }
Future refresh()async{
  setState(() {});
}
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(text: TextSpan(
                   children: [
                    TextSpan(text: "Chat", style: TextStyle(fontSize: 32, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800)),
                    TextSpan(text: "Sphere", style: TextStyle(fontSize: 32, color: Colors.grey),)
                   ]
                  )),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder:(context) => SettingsPage(),));}, icon: Icon(Icons.settings,color: Theme.of(context).primaryColor,)),
                    ))
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRequestWidget(),
                  Expanded(child: _buildUserList()),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:  Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                iconSize: IconTheme.of(context).size!*2,
                icon: Icon(Icons.add_comment_rounded,),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  addContactGetId();
                }
                ),
            ),
        // floatingActionButton: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: ElevatedButton(
        //         child: const Text("Add Contact"),
        //         onPressed: () {
        //           addContactGetId();
        //         }
        //         ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: ElevatedButton(
        //         child: const Text("sign out"),
        //         onPressed: () {
        //           signOut();
        //         }
        //         ),
        //     ),
        //   ],
        // )
      ),
    );
  }
  Widget _buildRequestWidget(){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("${FirebaseAuth.instance.currentUser!.uid}_contacts").snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
      List<String> requests = [];
          for (var doc in snapshot.data!.docs) {
            var data = doc.data();
            if (data.containsKey('requests')) {
              requests.addAll(List<String>.from(data['requests']));
            }
          }
          debugPrint("Requests: $requests");
      return
      requests.isNotEmpty?
       Padding(
         padding: const EdgeInsets.all(8.0),
         child: Container( 
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder:(context) => FriendRequestPage(friendRequestList: requests),));
            },
            title: Text("You've got a chat requiest",style: TextStyle(color: Colors.white),), 
          trailing: Text("${requests.length}",style: TextStyle(color: Colors.white)))),
       )
       :SizedBox();
    }else{
      return SizedBox();
    }
        },
    ); 
  }
  Widget _buildUserList(){
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder:(context, snapshot){
    if(snapshot.hasError){
      debugPrint(snapshot.error.toString());
      return const Text("🤕 error");
    }if(snapshot.connectionState==ConnectionState.waiting){
      return const Text("loading");
    }
    else{
      List<QueryDocumentSnapshot> users = snapshot.data!.docs;
      return RefreshIndicator(
        onRefresh: ()=>refresh(),
        child: ListView(
          children: snapshot.data!.docs.map<Widget>((doc) => _buildUserListItem(doc)).toList()
        ),
      );
    }
  },);
  }
  Widget _buildLastMessage(String reciverUserID){
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getMessages(reciverUserID, FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
        return _buildLastMessageItem(snapshot.data!.docs.reversed.toList().first);
        }
      
    },);
  }
  Widget _buildLastMessageItem(DocumentSnapshot documentSnapshot,){
 Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
 String sender = (data['senderId']==FirebaseAuth.instance.currentUser!.uid?"You: ":"");
 switch (data['messageType']) {
   case "text":
   return Text(sender+(data["message"]??""), style: TextStyle(fontWeight: FontWeight.bold),);
   default:
   return Text(sender+(data['messageType']??(data["message"]??"")), style: TextStyle(fontWeight: FontWeight.bold));
 }
 
 }
 Widget _buildUserListItem(DocumentSnapshot documentSnapshot){
    Map<String,dynamic> data = documentSnapshot.data()! as Map<String,dynamic>;
    Timestamp? lastVisited = data['lastVisited'];
    return FutureBuilder<String>(
       future: getNickNames(documentSnapshot),
  builder: (context, snapshot) {
    if(auth.currentUser!.email!=data['email']&&myContacts.contains(documentSnapshot.id)){
   //   addContact(documentSnapshot.id);
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: ListTile(
            subtitle: _buildLastMessage(data['uid']),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: FutureBuilder<String>(
                future: _getProfileImageUrl(data['uid']),
                builder: (context, snapshot) {
            if (!snapshot.hasData||kIsWeb) {
              return CircleAvatar(
                radius: 75,
                backgroundImage: CachedNetworkImageProvider(
                    "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
              );
            }else{
            String profileImageUrl = snapshot.data!;
            return GestureDetector(
              onTap: () {
                viewImage(context, profileImageUrl);
                debugPrint("ViewProfile");
              },
              child: CircleAvatar(
                radius: 75,
                backgroundImage: CachedNetworkImageProvider(profileImageUrl),
              ),
            );}
                },
              ),
          ),
          title: Text(snapshot.data??"loading..."),
          trailing: Text(
            lastVisited==null
            ?"undefined":
            (
              lastVisited.toDate().toString().substring(0,10)==Timestamp.now().toDate().toString().substring(0,10)
              ?
              (
                (Timestamp.now().seconds-lastVisited.seconds<100)
                ?
                "online"
                :
                lastVisited.toDate().toString().substring(11, 16)
                )
              :"${ChatService().toMonth(lastVisited.toDate().toString().substring(5, 7))} ${lastVisited.toDate().toString().substring(8, 16)} ")
              ),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder:(context) => ChatPage(reciverUserID: data['uid'], reciverUserEmail: data['email'],reciverUserName: snapshot.data!,),));
          },
        ),
      );
    }else{
      return Container();
    }});
  }
}