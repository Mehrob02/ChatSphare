// ignore_for_file: unused_local_variable, body_might_complete_normally_nullable, unused_import, unused_field, prefer_const_constructors, unused_element

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:chatsphere/services/settings/settings_service.dart';
import 'package:chatsphere/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:floating_menu_panel/floating_menu_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'as math;

import 'chat_page.dart';
import 'services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth =FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
//List companions = [];
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
    addContact(result);
    if (kDebugMode) {
      print('New contact: $result');
    }
  }

}
Future<void> addContact(String newContactId) async {
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

    // Получение текущих контактов пользователя
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
        .doc("my_contacts")
        .get();

    if (docSnapshot.exists) {
      List<dynamic> myContacts = docSnapshot['contacts'];
      // Проверка, что контакта еще нет в списке
      if (!myContacts.contains(newContactId)) {
        myContacts.add(newContactId);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
            .doc("my_contacts")
            .set({'contacts': myContacts});
        debugPrint("Contact added successfully");
      } else {
        debugPrint("You already have this contact");
      }
    } else {
      // Если документа не существует, создаем новый со списком контактов
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
          .doc("my_contacts")
          .set({'contacts': [newContactId]});
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
void signOut(){
final authService = Provider.of<AuthService>(context,listen: false);
final settingsService = Provider.of<SettingsService>(context,listen: false);
settingsService.colorChange(false);
authService.signOut();
// kIsWeb? RestartWeb() :
}
// void startNewChat()async{
// await showDialog(context: context, builder:(context) {
//   return AlertDialog(title: TextField(controller: textController,),
//   content: ElevatedButton(onPressed: (){
//     setState(() {
//       companions.add(textController.text);
//       textController.clear();
//     });
//     Navigator.pop(context);

//   }, child: const Text("ok")),
//   );
// },);
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.secondary, title: Text('User: ${auth.currentUser!.email!}', style:const TextStyle(color: Colors.white),),
      actions: [
        IconButton(onPressed:()=> Navigator.push(context, MaterialPageRoute(builder:(context) => SettingsPage(),)), icon: const Icon(Icons.settings, color: Colors.white,))
      ],
      ),
      body: Stack(
        children: [
          _buildUserList(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("Add Contact"),
              onPressed: () {
                addContactGetId();
              }
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("sign out"),
              onPressed: () {
                signOut();
              }
              ),
          ),
        ],
      )
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
      return ListView(
        children: snapshot.data!.docs.map<Widget>((doc) => _buildUserListItem(doc)).toList()
      );
    }
  },);
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
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
      //subtitle: Text("${data['email']}"),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: FutureBuilder<String>(
                future: _getProfileImageUrl(data['uid']),
                builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircleAvatar(
                radius: 75,
                backgroundImage: CachedNetworkImageProvider(
                    "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
              );
            }
            String profileImageUrl = snapshot.data!;
            return CircleAvatar(
              radius: 75,
              backgroundImage: CachedNetworkImageProvider(profileImageUrl),
            );
                },
              ),
          ),
          title: Text(snapshot.data??"loading..."),
          trailing: Text(
            lastVisited==null
            ?"Last visited: undefined":
            (
              lastVisited.toDate().toString().substring(0,10)==Timestamp.now().toDate().toString().substring(0,10)
              ?
              (
                (Timestamp.now().seconds-lastVisited.seconds<100)
                ?
                "online"
                :
                "Last visited: ${lastVisited.toDate().toString().substring(11, 16)}"
                )
              :"Last visited: ${ChatService().toMonth(lastVisited.toDate().toString().substring(5, 7))} ${lastVisited.toDate().toString().substring(8, 16)} ")
              ),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder:(context) => ChatPage(reciverUserID: data['uid'], reciveruserEmail: data['email'],),));
          },
        ),
      );
    }else{
      return Container();
    }});
  }
}