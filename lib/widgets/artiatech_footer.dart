
import 'package:flutter/material.dart';

class ArtiatechFooter extends StatelessWidget {
  const ArtiatechFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'powered by Artiatech Studio',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
