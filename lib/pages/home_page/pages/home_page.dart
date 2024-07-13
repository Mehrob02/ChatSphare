// ignore_for_file: unused_local_variable, body_might_complete_normally_nullable, unused_import, unused_field, prefer_const_constructors, unused_element, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/pages/home_page/pages/friend_request_page.dart';
import 'package:chatsphere/models/message.dart';
import 'package:chatsphere/pages/home_page/widgets/build_user_list.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'as math;

import '../../chat_page/pages/chat_page.dart';
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
      await firebaseFirestore.collection("users").doc(auth.currentUser!.uid).update({
      "lastVisited":Timestamp.now(),
    });
    } catch (e) {
      debugPrint("ooops");
    }

  }
 
  @override
  void dispose() {
    super.dispose();
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
                      child: IconButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder:(context) => 
                          SettingsPage()));},
                            icon: Icon(Icons.settings,color: Theme.of(context).primaryColor,)),
                    ))
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(FontAwesomeIcons.magnifyingGlass),
                        hintText: "Search",
                      ),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  SizedBox(height: 10,),
                  _buildRequestWidget(),
               //   _buildLastChats(),
                  Expanded(child: BuildUserList()),

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
              Navigator.push(context, MaterialPageRoute(builder:(context) => FriendRequestPage(friendRequestList: requests, onAccept:loadContacts),));
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
  
   
 }