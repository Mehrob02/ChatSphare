import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}
class _SecurityPageState extends State<SecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
         child: ElevatedButton(onPressed: (){}, child: const Text("Change password")),
        ),
    );
  }
}
class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start at the top left corner
    path.moveTo(0, 0);

    // Draw a curve to the bottom right corner
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.25, size.width, size.height);

    // Close the path to form a triangle
    path.lineTo(size.width, 0);
    path.close();

    // Draw the path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}