// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chatsphere/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.pageController});
  final PageController pageController;
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController= TextEditingController();
   final passwordController= TextEditingController();
   
   void signIn()async{
    final authService = Provider.of<AuthService>(context,listen: false);
    try {
      await authService.signInWithEmailAndPassword(emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome Back!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
            SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width*.8, child: TextField(decoration: InputDecoration(border: OutlineInputBorder()), controller: emailController,)),
                SizedBox(height: 10,),
                SizedBox(width: MediaQuery.of(context).size.width*.8, child: TextField(decoration: InputDecoration(border: OutlineInputBorder()), controller: passwordController,)),
                SizedBox(height: 10,),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*.6,
              child: ElevatedButton(onPressed: (){
                signIn();
              },child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Submit"),
              ),),
            ),
            SizedBox(height: 10,),
           kDebugMode? SizedBox(
              width: MediaQuery.of(context).size.width*.6,
              child: ElevatedButton(onPressed: (){
                widget.pageController.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.linear);
              },child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Sign Up"),
              ),),
            ):SizedBox(),
          ],
        ),
      ),
    );
  }
}