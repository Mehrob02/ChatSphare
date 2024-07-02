// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/widgets/notification_body.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.profileId, required this.name, required this.email, this.about, required this.goBack,});
 final String profileId;
 final String name;
 final String email;
 final String? about;
 final VoidCallback goBack;
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.45,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onBackground,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.name, style: TextStyle(fontSize: 20),),
                                SizedBox(height: 5,),
                                Text(widget.email, style: TextStyle(fontSize: 15),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ), 
              ),
              Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: widget.goBack, icon: Icon(Icons.arrow_back_ios_new_rounded, )),
             IconButton(onPressed: (){
               InAppNotification.show(
                  child: NotificationBody(child: Text("On working, yet :)"),),
                context: context,
                onTap: () => (){},
                  );
             }, icon: Icon(Icons.notification_add_rounded, )),
            ],
          ),
              Container(
                height: MediaQuery.of(context).size.height*0.45,
                alignment: Alignment.center,
                        child: FutureBuilder<String>(
                          future: _getProfileImageUrl(widget.profileId),
                          builder: (context, snapshot) {
                      if (snapshot.hasData&&!kIsWeb) {
                         String profileImageUrl = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.onBackground, width: 4)
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(profileImageUrl),
                        ),
                      );
                      }else{return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.onBackground, width: 4)
                        ),
                        child: CircleAvatar(
                          radius: 50,
                            backgroundImage: CachedNetworkImageProvider(
                                "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png"),
                          ),
                      );
                     }
                          },
                        ),
              ),
            ],
          ),
          SizedBox(height: 10,),
           buildCard('About', Icons.info_outline_rounded, Text(widget.about??"nothing about provided", style: TextStyle(fontWeight: FontWeight.bold),))
          ],
        ),
      ),
    );
  }
  Widget buildCard(String title, IconData titleIcon, Widget body){
    return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.onBackground
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title),
                        Icon(titleIcon)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: body,
                    ),
                  ],
                ),
              ));
  }
}