import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
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

class _BoardDimensions {
  final double cellSize;
  final double boardWidth;
  final double boardHeight;

  _BoardDimensions({
    required this.cellSize,
    required this.boardWidth,
    required this.boardHeight,
  });

  static _BoardDimensions calculateBoardDimensions(BoxConstraints constraints) {
    final cellSize = min(
      constraints.maxWidth / Connect4Board.columns,
      constraints.maxHeight / Connect4Board.rows,
    );
    return _BoardDimensions(
      cellSize: cellSize,
      boardWidth: cellSize * Connect4Board.columns,
      boardHeight: cellSize * Connect4Board.rows,
    );
  }
}

/// A stateful widget that represents the Connect 4 game board.
/// 
/// This widget creates a 7 × 6 grid layout with circular placeholders
/// for empty slots. It supports animated chip drops and updates the
/// board state dynamically. The widget is reusable and manages its
/// own state for animations and board updates.
class Connect4Board extends StatefulWidget {
  static const int columns = 7; // Number of columns in the grid
  static const int rows = 6; // Number of rows in the grid
  static const double spacing = 4.0; // Spacing between grid cells
  static const int droppingChipAnimationMs = 50; // Animation duration for each step of the dropping chip

  const Connect4Board({super.key});

  @override
  State<Connect4Board> createState() => _Connect4BoardState();
}

class _Connect4BoardState extends State<Connect4Board> {
  final List<List<Connect4SquareState>> board = List.generate(
    Connect4Board.rows,
    (_) => List.filled(Connect4Board.columns, Connect4SquareState.empty),
  );

  int? _droppingChipColumn;
  int? _droppingChipRow;
  Connect4SquareState? _droppingChipColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimensions = _BoardDimensions.calculateBoardDimensions(constraints);

        return Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: dimensions.boardWidth,
                  height: dimensions.boardHeight,
                  child: Stack(
                    children: [
                      _buildGrid(dimensions.cellSize),
                      _buildAnimatedChip(dimensions.cellSize),
                    ],
                  ),
                ),
              ),
            ),
            if (kDebugMode) _buildDebugControls(dimensions.cellSize),
          ],
        );
      },
    );
  }
  
  Widget _buildGrid(double cellSize) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Connect4Board.columns,
        mainAxisSpacing: Connect4Board.spacing,
        crossAxisSpacing: Connect4Board.spacing,
      ),
      itemCount: Connect4Board.columns * Connect4Board.rows,
      itemBuilder: (context, index) {
        final row = index ~/ Connect4Board.columns;
        final column = index % Connect4Board.columns;
        return Container(
          decoration: BoxDecoration(
            color: _getSquareColor(board[row][column]),
            border: Border.all(color: Colors.black),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedChip(double cellSize) {
    if (_droppingChipColumn == null || _droppingChipRow == null || _droppingChipColor == null) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: Connect4Board.droppingChipAnimationMs),
      curve: Curves.easeIn,
      left: _droppingChipColumn! * cellSize,
      top: _droppingChipRow! * cellSize,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: _getSquareColor(_droppingChipColor!), // Use the correct chip color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDebugControls(double cellSize) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(Connect4Board.columns, (column) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () => _dropChip(column, Connect4SquareState.red),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(cellSize, cellSize / 2),
                  ),
                  child: const Text('R'),
                ),
                ElevatedButton(
                  onPressed: () => _dropChip(column, Connect4SquareState.yellow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    minimumSize: Size(cellSize, cellSize / 2),
                  ),
                  child: const Text('Y'),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        const Text(
          'Debug Mode: Use buttons to drop chips',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _dropChip(int column, Connect4SquareState chipColor) {
    final row = Connect4GameLogic.getTargetRow(board, column);
    if (row == null) return;

    setState(() {
      _droppingChipColumn = column;
      _droppingChipRow = 0; // Start animation from the top
      _droppingChipColor = chipColor; // Set the color of the dropping chip
    });

    // Simulate the falling animation by incrementally updating the row
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: Connect4Board.droppingChipAnimationMs));
      if (_droppingChipRow! < row) {
        setState(() {
          _droppingChipRow = _droppingChipRow! + 1;
        });
        return true; // Continue the animation
      } else {
        return false; // Stop the animation
      }
    }).then((_) {
      // Finalize the chip placement
      setState(() {
        board[row][column] = chipColor;
        _droppingChipColumn = null;
        _droppingChipRow = null;
        _droppingChipColor = null;
      });
    });
  }

  Color _getSquareColor(Connect4SquareState state) {
    switch (state) {
      case Connect4SquareState.empty:
        return Colors.blue[100]!;
      case Connect4SquareState.red:
        return Colors.red;
      case Connect4SquareState.yellow:
        return Colors.yellow;
    }
  }
}
