// ignore_for_file: prefer_const_constructors

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  
   String _token = '';

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token ?? '';
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Обработка полученного пуш-уведомления
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Home Screen')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Token: $_token'),
              ElevatedButton(onPressed: (){
              if(_token.isNotEmpty) {
                Clipboard.setData(ClipboardData(text:_token));
              }else{
                setState(() {
                  
                });
              }
              }, child: Text("Copy token"))
            ],
          ),
        ),
      ),
    );
  }
}