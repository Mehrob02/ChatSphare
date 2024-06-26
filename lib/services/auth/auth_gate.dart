// ignore_for_file: prefer_const_constructors

import 'package:chatsphere/LogIn&Registration/sign.dart';
import 'package:chatsphere/pages/home_page/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
   final settingsService = Provider.of<SettingsService>(context);
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
         if(snapshot.hasData){
          settingsService.email=snapshot.data!.email!;
          return HomePage();
        }else{
         return Sign();
        }
      },),
    );
  }
}