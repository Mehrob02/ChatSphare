// ignore_for_file: unused_import, prefer_const_constructors

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/painter.dart';
import 'package:flutter/material.dart';

enum ProfileStatus {online, offline}
Set numbers ={1,2,"3","4"};
ProfileStatus changeStatus(ProfileStatus currentStatus){
switch (currentStatus) {
  case ProfileStatus.offline:
    return ProfileStatus.online;
  case ProfileStatus.online:
   return ProfileStatus.offline;
}
}
class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}
ProfileStatus profileStatus = ProfileStatus.offline;
class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: Scaffold(
        body: Center(
          child: Column(
            children: [
              RawMaterialButton(
                onPressed: () {
                  setState(() {
                   profileStatus= changeStatus(profileStatus);
                   numbers.clear();
                  });
                },
                child: Text("Change Status"),
              ),
              Text(profileStatus.name),
              Text(numbers.toString())
            ],
          ),
        ),
      ),
    );
  }
}