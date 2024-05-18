import 'package:flutter/material.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key, required this.child});
  final Widget child;
  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.child,
      ),
    );
  }
}