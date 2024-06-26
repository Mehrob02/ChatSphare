import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../services/chat/chat_service.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({super.key, required this.friendRequestList});
  final List friendRequestList;
  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final ChatService chatService = ChatService();
  String name = "Loading";

  Future<void> addToFriendContact(String newContactId) async {
    try {
      // Проверка, существует ли пользователь с таким ID
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (!userDocSnapshot.exists) {
        debugPrint("User does not exist");
        return;
      }

      // Получение текущих контактов пользователя
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(newContactId)
          .collection("${newContactId}_contacts")
          .doc("my_contacts")
          .get();

      if (docSnapshot.exists) {
        List<dynamic> myContacts = docSnapshot['contacts'];
        // Проверка, что контакта еще нет в списке
        if (!myContacts.contains(FirebaseAuth.instance.currentUser!.uid)) {
          myContacts.add(FirebaseAuth.instance.currentUser!.uid);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(newContactId)
              .collection("${newContactId}_contacts")
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
            .doc(newContactId)
            .collection("${newContactId}_contacts")
            .doc("my_contacts")
            .set({'contacts': [FirebaseAuth.instance.currentUser!.uid]});
        debugPrint("Contact added successfully");
      }
    } catch (e) {
      debugPrint("Error adding contact: $e");
    }
  }

  Future<void> addToMyContact(String newContactId) async {
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

  Future<void> acceptTheRequest(String friendId) async {
    try {
      final tokenDoc = await FirebaseFirestore.instance
          .collection("users_tokens")
          .doc(friendId)
          .get();
      final token = tokenDoc.data()?['token'];
      await chatService.sendNotification(
        serverKey,
        "Accepted a chat request",
        token,
      );
      addToMyContact(friendId);
      addToFriendContact(friendId);
      removeTheRequest(friendId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> rejectTheRequest(String friendId) async {
    try {
      final tokenDoc = await FirebaseFirestore.instance
          .collection("users_tokens")
          .doc(friendId)
          .get();
      final token = tokenDoc.data()?['token'];
      await chatService.sendNotification(
        serverKey,
        "Rejected a chat request",
        token,
      );
      removeTheRequest(friendId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> removeTheRequest(String friendId) async {
    try {
      // Проверка, существует ли пользователь с таким ID
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (!userDocSnapshot.exists) {
        debugPrint("User does not exist");
        return;
      }
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
          .doc("my_requests")
          .get();

      if (docSnapshot.exists) {
        List<dynamic> myRequests = docSnapshot['requests'];
        debugPrint("$myRequests");
        // Проверка, что контакта еще нет в списке
        if (myRequests.contains(friendId)) {
          myRequests.remove(friendId);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
              .doc("my_requests")
              .set({'requests': myRequests});
          debugPrint("Contact added successfully");
        } else {
          debugPrint("You already have this contact");
        }
      } else {
        // Если документа не существует, создаем новый со списком контактов
        debugPrint("Contact doesent exist");
      }
    } catch (e) {
      debugPrint("Error adding contact: $e");
    }
  }

  Future<String> _getProfileImageUrl(String recieverId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('user_profile_images/$recieverId.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // Если изображение не найдено или произошла ошибка, возвращаем URL изображения по умолчанию
      return "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png";
    }
  }

  Future<String> getNickNames(String uid) async {
    DocumentSnapshot nickNameSnapshot =
        await FirebaseFirestore.instance.collection("nickNames").doc(uid).get();
    Map<String, dynamic> nickNamesData =
        nickNameSnapshot.data() as Map<String, dynamic>;
    String nickName = nickNamesData['nickName'];
    return nickName;
  }

  Widget _buildRequestWidget(Widget childWidget) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("${FirebaseAuth.instance.currentUser!.uid}_contacts")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> requests = [];
          for (var doc in snapshot.data!.docs) {
            var data = doc.data();
            if (data.containsKey('requests')) {
              requests.addAll(List<String>.from(data['requests']));
            }
          }
          debugPrint("Requests: $requests");
          return requests.isNotEmpty ? childWidget : const SizedBox();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildRequestWidget(
              ListView.builder(
                itemCount: widget.friendRequestList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: FutureBuilder<String>(
                            future: _getProfileImageUrl(
                                widget.friendRequestList[index]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                String profileImageUrl = snapshot.data!;
                                return CircleAvatar(
                                  radius: 75,
                                  backgroundImage: CachedNetworkImageProvider(
                                      profileImageUrl),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                        title: FutureBuilder(
                          future: getNickNames(widget.friendRequestList[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Loading");
                            } else if (snapshot.hasData) {
                              name = snapshot.data!;
                              return Text(name);
                            } else {
                              return const Text("Loading");
                            }
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    acceptTheRequest(
                                        widget.friendRequestList[index]);
                                  });
                                },
                                icon: const Icon(Icons.check)),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    removeTheRequest(
                                        widget.friendRequestList[index]);
                                  });
                                },
                                icon:
                                    const Icon(Icons.cancel_presentation_rounded))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
