// ignore_for_file: prefer_const_constructors, unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatsphere/models/message.dart';
import 'package:chatsphere/widgets/notification_body.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:photo_view/photo_view.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key, required this.child, required this.timestamp, required this.aligment, this.replyTo, this.messageType, this.replyToId,});
  final Widget child;
  final String timestamp;
  final Alignment aligment;
  final String? replyTo;
  final String? replyToId;
  final MessageType? messageType;
  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color:widget.aligment==Alignment.centerRight? Theme.of(context).primaryColor.withOpacity(0.65):Theme.of(context).colorScheme.onSecondary,
            borderRadius:widget.aligment==Alignment.centerRight? BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10), bottomRight: Radius.circular(13)):BorderRadius.only( topRight: Radius.circular(10), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(10),),

          ),
          
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:widget.aligment==Alignment.centerRight? CrossAxisAlignment.end:CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: widget.child,
                ),
                Text(" ${widget.timestamp}", style: TextStyle(color:Theme.of(context).primaryColor,fontSize: 12),)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
