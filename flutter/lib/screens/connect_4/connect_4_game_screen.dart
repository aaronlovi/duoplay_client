import 'package:flutter/material.dart';

class Connect4GameScreen extends StatelessWidget {
  const Connect4GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect 4')),
      body: const Center(
        child: Text('Connect 4', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
