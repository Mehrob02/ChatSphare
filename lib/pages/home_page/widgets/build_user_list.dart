// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/pages/chat_page/pages/chat_page.dart';
import 'package:chatsphere/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class BuildUserList extends StatefulWidget {
  const BuildUserList({super.key});

  @override
  State<BuildUserList> createState() => _BuildUserListState();
}
 
class _BuildUserListState extends State<BuildUserList> {
  Future refresh()async{
  setState(() {});
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
Widget _buildUserListItem(DocumentSnapshot documentSnapshot, List contacts){
    Map<String,dynamic> data = documentSnapshot.data()! as Map<String,dynamic>;
    Timestamp? lastVisited = data['lastVisited'];
    if(FirebaseAuth.instance.currentUser!.email!=data['email']&&contacts.contains(documentSnapshot.id)){
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
          title: Text(data['nickName']??"loading..."),
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
if(data['nickName']==null){
refresh();
}else{
              Navigator.push(context, MaterialPageRoute(builder:(context) => ChatPage(reciverUserID: data['uid'], reciverUserEmail: data['email'],reciverUserName: data['nickName']!, about: data['about'],),));

}
          },
        ),
      );
    }else{
      return Container();
    }}  
    Widget _buildLastMessage(String receiverUserID) {
    // Ограничиваем запрос последним сообщением
    List<String> ids = [FirebaseAuth.instance.currentUser!.uid, receiverUserID];
  ids.sort();
  String chatRoomId = ids.join("_");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
          return const SizedBox();
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return _buildLastMessageItem(snapshot.data!.docs.first);
        } else {
          return const Text('No messages yet');
        }
      },
    );
  }
  Widget _buildLastMessageItem(DocumentSnapshot documentSnapshot,){
 Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
 String sender = (data['senderId']==FirebaseAuth.instance.currentUser!.uid?"You: ":"");
 switch (data['messageType']) {
   case "text":
   return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
     children: [
            if(data['senderId']!=FirebaseAuth.instance.currentUser!.uid&&data['isRead']!=null&&!data['isRead']) Icon(Icons.circle, size: IconTheme.of(context).size!*0.5, color: Theme.of(context).primaryColor,),
           SizedBox(width: 4,), 
       Expanded(child: Text(sender+(data["message"]??""), style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis,),maxLines: 1, overflow: TextOverflow.ellipsis,)),
       
     ],
   );
   default:
   return Text(sender+(data['messageType']??(data["message"]??"")), style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),maxLines: 1,);
 }
 
 }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("${FirebaseAuth.instance.currentUser!.uid}_contacts").snapshots(),
      builder: (context, contactSnapshot) {
        if (contactSnapshot.hasData) {
          List<String> contacts = [];
          for (var doc in contactSnapshot.data!.docs) {
            var data = doc.data();
            if (data.containsKey('contacts')) {
              contacts.addAll(List<String>.from(data['contacts']));
            }
          }
          debugPrint("Requests: $contacts");
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                return const Text("🤕 error");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("loading");
              } else {
                List<QueryDocumentSnapshot> users = snapshot.data!.docs;
                // Сортируем пользователей по полю lastVisited
                users.sort((a, b) {
                  Timestamp? lastVisitedA = a['lastVisited'];
                  Timestamp? lastVisitedB = b['lastVisited'];
                  if (lastVisitedA == null && lastVisitedB == null) {
                    return 0;
                  } else if (lastVisitedA == null) {
                    return 1;
                  } else if (lastVisitedB == null) {
                    return -1;
                  } else {
                    return lastVisitedB.compareTo(lastVisitedA);
                  }
                });

                return RefreshIndicator(
                  onRefresh: () => refresh(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: users.map<Widget>((doc) => _buildUserListItem(doc, contacts)).toList(),
                    ),
                  ),
                );
              }
            },
          );
        } else {
          return const Text("loading");
        }
      },
    );
  }
}