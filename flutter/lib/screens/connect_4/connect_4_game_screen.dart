import 'dart:math';

import 'package:flutter/material.dart';

class Connect4GameScreen extends StatelessWidget {
  const Connect4GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect 4')),
      body: const Center(child: Connect4Board()),
    );
  }
}

class Connect4Board extends StatelessWidget {
  static const int columns = 7; // Number of columns in the grid
  static const int rows = 6; // Number of rows in the grid
  static const double spacing = 4.0; // Spacing between grid cells

  const Connect4Board({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the size of each cell to maintain a 7:6 aspect ratio
        final cellSize = min(
          constraints.maxWidth / columns,
          constraints.maxHeight / rows,
        );
        final boardWidth = cellSize * columns;
        final boardHeight = cellSize * rows;

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
              ),
              itemCount: columns * rows,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100], // Placeholder color for empty slots
                    border: Border.all(color: Colors.black),
                    shape: BoxShape.circle, // Representing empty slots as circles
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
