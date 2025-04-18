import 'dart:math';
import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';

class Connect4BeginnerEngine implements Connect4EngineContract {
  @override
  int getMove(List<List<Connect4SquareState>> board, Connect4SquareState chipColor) {
    // Check for a winning move
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        // Simulate the move
        final simulatedBoard = board.map((row) => List<Connect4SquareState>.from(row)).toList();
        Connect4GameLogic.applyMove(simulatedBoard, col, chipColor);

        // Check if this move wins the game
        if (Connect4GameLogic.getWinner(simulatedBoard) == chipColor) {
          return col;
        }
      }
    }

    // Otherwise, pick a random legal column
    final legalColumns = <int>[];
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        legalColumns.add(col);
      }
    }

    return legalColumns[Random().nextInt(legalColumns.length)];
  }
}
