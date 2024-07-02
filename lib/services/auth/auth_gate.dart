// ignore_for_file: prefer_const_constructors

import 'package:chatsphere/LogIn&Registration/sign.dart';
import 'package:chatsphere/pages/home_page/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
         if(snapshot.hasData){
          return HomePage();
        }else{
         return Sign();
        }
      },),
    );
  }
}