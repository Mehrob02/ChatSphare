// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chatsphere/LogIn&Registration/sign_in.dart';
import 'package:chatsphere/LogIn&Registration/sign_up.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}
class _SignState extends State<Sign> {
  final PageController _pageController = PageController();
  Color signInColor = Colors.deepPurple; 
  Color signUpColor = Colors.deepPurple; 
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children:[ 
        Scaffold(
       body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(transform: GradientRotation(1), colors: [Colors.deepPurple,Colors.indigo,Colors.blue], begin: Alignment.topRight, end: Alignment.bottomLeft),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Column(
               children: [
                 Icon(Icons.bubble_chart_rounded, size: 100, color: Colors.white,),
                 Text("ChatSphere",style:TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.white))
               ],
             ),
             SizedBox(height: MediaQuery.of(context).size.height*.2,),
             Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*.8,
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(signInColor), foregroundColor: MaterialStatePropertyAll((signInColor==Colors.deepPurple)? Colors.white:Colors.black)),
                    onHover: (value) {
                       setState(() {
                         signInColor = !value ? Colors.deepPurple : Colors.white;
                       });
                    },
                    onPressed: (){
                    _pageController.animateToPage(1, duration: Duration(milliseconds: 700), curve: Curves.linear);
                  }, child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:15.0),
                    child: Text("Sign in"),
                  )),
                ),
                SizedBox(height: 10),
              kDebugMode? SizedBox(
                  width: MediaQuery.of(context).size.width*.8,
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(signUpColor), foregroundColor: MaterialStatePropertyAll((signUpColor==Colors.deepPurple)? Colors.white:Colors.black)),
                    onHover: (value) {
                       setState(() {
                         signUpColor = !value ? Colors.deepPurple : Colors.white;
                       });
                    },
                    onPressed: (){
                    _pageController.animateToPage(2, duration: Duration(milliseconds: 700), curve: Curves.linear);
                  }, child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:15.0),
                    child: Text("Sign Up"),
                  )),
                ):SizedBox(),
              ],
             )
          ]),
        ),
      ),
      SignInPage(pageController: _pageController,),
      SignUpPage(pageController: _pageController,)
      ]
    );
  }
}