// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PlayersCard extends StatefulWidget {
  const PlayersCard({
    Key? key,
    required this.firstMatch,
    required this.secondMatch,
    required this.matchWinner,
  }) : super(key: key);

  final Map<String, int> firstMatch;
  final Map<String, int> secondMatch;
  final Map<String, int> matchWinner;

  @override
  State<PlayersCard> createState() => _PlayersCardState();
}

class _PlayersCardState extends State<PlayersCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildCard(
                    widget.firstMatch.keys.toList()[0],
                    widget.firstMatch.keys.toList()[1],
                    widget.firstMatch.values.toList()[0],
                    widget.firstMatch.values.toList()[1],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildCard(
                    widget.secondMatch.keys.toList()[0],
                    widget.secondMatch.keys.toList()[1],
                    widget.secondMatch.values.toList()[0],
                    widget.secondMatch.values.toList()[1],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                        painter: BracketPainter(),
                        child: Container(),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCard(
                widget.matchWinner.keys.toList()[0],
                widget.matchWinner.keys.toList()[1],
                widget.matchWinner.values.toList()[0],
                widget.matchWinner.values.toList()[1],
              ),
            ),
          ],
        ),
        
      ],
    );
  }

  Widget _buildCard(
      String player1, String player2, int player1Score, int player2Score) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    player1,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    player1Score.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    player2,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    player2Score.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    // Coordinates for the lines between the match cards
    final firstMatchBottom = Offset(size.width * 0.2, size.height * 0.2);
    final secondMatchTop = Offset(size.width * 0.2, size.height * 0.8);
    final winnerCenter = Offset(size.width * 0.7, size.height * 0.5);

    // Draw lines connecting the match cards to the winner card
    canvas.drawLine(firstMatchBottom, winnerCenter, paint);
    canvas.drawLine(secondMatchTop, winnerCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
