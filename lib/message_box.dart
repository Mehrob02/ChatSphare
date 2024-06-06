// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key, required this.child, required this.timestamp, required this.aligment});
  final Widget child;
  final String timestamp;
  final Alignment aligment;
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
            color:widget.aligment==Alignment.centerRight? Theme.of(context).primaryColor:Theme.of(context).colorScheme.onSecondary,
            borderRadius:widget.aligment==Alignment.centerRight? BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10), bottomRight: Radius.circular(13)):BorderRadius.only( topRight: Radius.circular(10), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(10),),

          ),
          
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.child,
                Text(" ${widget.timestamp}", style:const TextStyle(color: Colors.grey,fontSize: 10),)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
