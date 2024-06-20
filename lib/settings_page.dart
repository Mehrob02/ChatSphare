// ignore_for_file: unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/security_page.dart';
import 'package:chatsphere/theme_provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'account_view_page.dart';
import 'customisation_page.dart';
import 'services/settings/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
void switchNotification(){
  if(!kIsWeb){
    debugPrint("Switching Notification");
  }
}
void showAbout(){
  showAboutDialog(
    applicationVersion: "1.0",
    applicationName: "Chatsphere",
    applicationLegalese: "...",
    applicationIcon: kIsWeb? Image.asset("AppIcons/appstore.png", width: IconTheme.of(context).size!*2,height: IconTheme.of(context).size!*2,):ImageIcon(AssetImage("assets/AppIcons/appstore.png")),
    context: context
  );
}
@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) { 
    final settingsService = Provider.of<SettingsService>(context);
    final themeProvider = Provider.of<UiProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back_ios),
                          ),
                          GestureDetector(
                            child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold),),
                          )
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:FutureBuilder<String>(
              future:settingsService.getProfileImageUrl(),
              builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircleAvatar(
              radius: 75,
              backgroundImage: CachedNetworkImageProvider(
                  "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png", errorListener:(p0) {
                    
                  },),
            );
          }
          String profileImageUrl = snapshot.data!;
          return CircleAvatar(
            radius: 75,
            backgroundImage: CachedNetworkImageProvider(profileImageUrl),
          );
              },
            )
                                ),
                         
                            Text(settingsService.userNickName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            Text(settingsService.email),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                          themeProvider.changeTheme();
                                        });
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.dark_mode,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Dark Mode",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Switch(
                                      value: themeProvider.isDark,
                                      onChanged: (value) {
                                        setState(() {
                                          themeProvider.changeTheme();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                       setState(() {
                                          switchNotification();
                                        });
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.notifications,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Notification",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Switch(
                                      value: true,
                                      onChanged: (value) {
                                        setState(() {
                                          switchNotification();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder:(context) => CustomisationPage(),));
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.color_lens,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Customisation",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap:(){
                                      Navigator.push(context, MaterialPageRoute(builder:(context) => SecurityPage(),));
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.security_sharp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Security",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder:(context) => AccountViewPage(),));
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.account_circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "Account",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: (){
                                      showAbout();
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.info,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      "About",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}