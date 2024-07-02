import 'package:flutter/material.dart';

class SearchMessage extends StatefulWidget {
  const SearchMessage({super.key});
  @override
  State<SearchMessage> createState() => _SearchMessageState();
}

class _SearchMessageState extends State<SearchMessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Message'),
      ),
      body: const Center(
        child: Text('Search Message'),
        ),
    );
  }
}