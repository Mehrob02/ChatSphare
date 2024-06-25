// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'services/auth/auth_service.dart';
import 'services/settings/settings_service.dart';

class AccountViewPage extends StatefulWidget {
  const AccountViewPage({super.key});

  @override
  State<AccountViewPage> createState() => _AccountViewPageState();
}

class _AccountViewPageState extends State<AccountViewPage> {
  void loadProfileImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      final storageReference = FirebaseStorage.instance.ref().child(
          'user_profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => setState(() {}));
      setState(() {});
    }
  }
 void editName() async {
  String newName = ''; // Инициализация пустой строкой
  String? result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter new name'),
        content: TextField(
          onChanged: (value) {
            newName = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(newName);
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
    // Используйте result, чтобы обновить имя пользователя
    if (kDebugMode) {
      print('New name: $result');
    }
  }
}


  void editEmail()async{
 String newEmail = ''; // Инициализация пустой строкой
  String? result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter new email'),
        content: TextField(
          onChanged: (value) {
            newEmail = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(newEmail);
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
    if (kDebugMode) {
      print('New email: $result');
    }
  }
  }
  void signOut(){
final authService = Provider.of<AuthService>(context,listen: false);
final settingsService = Provider.of<SettingsService>(context,listen: false);
settingsService.colorChange(false);
authService.signOut();
// kIsWeb? RestartWeb() :
}
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<String>(
                      future: settingsService.getProfileImageUrl(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircleAvatar(
                            radius: 75,
                            backgroundImage: CachedNetworkImageProvider(
                              "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png",
                              errorListener: (p1) {},
                            ),
                          );
                        }
                        String profileImageUrl = snapshot.data!;
                        return CircleAvatar(
                          radius: 75,
                          backgroundImage:
                              CachedNetworkImageProvider(profileImageUrl),
                        );
                      },
                    )),
                Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (!kIsWeb) {
                          loadProfileImage();
                        }
                      },
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    ))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(settingsService.userNickName),
                IconButton(onPressed: (){setState(() {editName();});}, icon: Icon(Icons.edit))
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(settingsService.email),
                IconButton(onPressed: (){setState(() {editEmail();});}, icon: Icon(Icons.edit))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Your id: ${FirebaseAuth.instance.currentUser!.uid}"),
                IconButton(onPressed: (){setState(() {  Clipboard.setData(ClipboardData(text: FirebaseAuth.instance.currentUser!.uid));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
          ),
        );
          debugPrint("Shoud Copy");});}, icon: Icon(Icons.copy))
              ],
            ),
             Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("sign out"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                signOut();
              }
              ),
          ),
          ],
        ),
      ),
    );
  }
}
