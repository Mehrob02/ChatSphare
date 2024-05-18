// ignore_for_file: unused_local_variable, body_might_complete_normally_nullable, unused_import, unused_field

import 'dart:async';

import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:chatsphere/services/settings/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floating_menu_panel/floating_menu_panel.dart';
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
//  final textController=TextEditingController();
//List companions = [];
@override
  void initState() {
   Timer.periodic(const Duration(seconds: 60), (timer) {
    setLastTimeEntered();
  });
    super.initState();
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
  
  @override
  void dispose() {
    super.dispose();
  }
void signOut(){
final authService = Provider.of<AuthService>(context,listen: false);
authService.signOut();
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
 // final settingsService = Provider.of<SettingsService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('User: ${auth.currentUser!.email!}'),),
      body: Stack(
        children: [
          _buildUserList(),
  //          FloatingMenuPanel(
  //     panelIcon: Icons.format_color_fill_rounded,
  //     onPressed: (a) {
  //     settingsService.changeAppColor(appColors[a]);
  //   },
  //   buttonColors: appColors,
  //   buttons: icons,
  //  backgroundColor: settingsService.appColor,
  //      ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        child: const Text("sign out"),
        onPressed: () {
          signOut();
        }
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
    //if(!snapshot.){
    //   return const Center(
    //     child: Text("🤕 No user found"),
    //   );
    // }
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
    if(auth.currentUser!.email!=data['email']){
      return ListTile(
        subtitle: Text("${data['email']}"),
        leading: const Icon(Icons.person),
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
      );
    }else{
      return Container();
    }});
  }
}