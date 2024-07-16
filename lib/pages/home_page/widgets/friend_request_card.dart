// ignore_for_file: prefer_const_constructors, unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../../services/chat/chat_service.dart';

class FriendRequestCard extends StatefulWidget {
  const FriendRequestCard(this.friendId,{super.key, });
  final String friendId;
  @override
  State<FriendRequestCard> createState() => _FriendRequestCardState();
}


class _FriendRequestCardState extends State<FriendRequestCard> {
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child:
       ListTile(
      ),
    );
  }
}