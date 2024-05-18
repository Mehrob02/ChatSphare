// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.pageController});
  final PageController pageController;
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController= TextEditingController();
  final passwordController= TextEditingController();
  final nameController= TextEditingController();

void signUp()async{
   final authService = Provider.of<AuthService>(context,listen: false);
    try {
      await authService.signUpWithEmailAndPassword(emailController.text, passwordController.text, nameController.text);
      await authService.signInWithEmailAndPassword(emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Create a new Accaunt!",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
              SizedBox(height: 10,),
              Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width*.8, child: TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText:"Email"), controller: emailController,)),
                SizedBox(height: 10,),
                SizedBox(width: MediaQuery.of(context).size.width*.8, child: TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText:"Password"), controller: passwordController,)),
                SizedBox(height: 10,),
                SizedBox(width: MediaQuery.of(context).size.width*.8, child: TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText:"Nickname"), controller: nameController,)),
              ],
            ),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: (){
                signUp();
              }
              ,child: Text("Submit"),),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: (){
                      widget.pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.linear);
                    }, child: Text("Sign in")),
            ],
          ),
        ),
      ),
    );
  }
}