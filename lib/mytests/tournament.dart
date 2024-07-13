// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chatsphere/mytests/players_card.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Tournament(),
  ));
}
class Tournament extends StatefulWidget {
  const Tournament({super.key});

  @override
  State<Tournament> createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Color.fromARGB(255, 52, 49, 49),
      body: Row(
        children: [
          Column(
            children: [
           PlayersCard(firstMatch: {"fsdf":4, "sdds":5}, secondMatch: {"sdsf":4, "tyjt":5}, matchWinner: {"ytty":4, "sdds":5})
            ],
          )
        ],
      ),
    );
  }
}