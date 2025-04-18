import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'dart:math';

import 'connect_4_beginner_engine.dart';

class Connect4IntermediateEngine extends Connect4BeginnerEngine {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    List<List<Connect4SquareState>> board = currentState.board;
    Connect4SquareState chipColor = currentState.currentPlayer;

    // Check for a winning move
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        // Simulate the move
        final simulatedBoard = board.map((row) => List<Connect4SquareState>.from(row)).toList();
        Connect4GameLogic.applyMove(simulatedBoard, col, chipColor);

        // Check if this move wins the game
        if (Connect4GameLogic.getWinner(simulatedBoard) == chipColor) {
          return GenericResult<int>.success(col);
        }
      }
    }

    // Check for a blocking move
    final opponentChipColor = chipColor == Connect4SquareState.red
        ? Connect4SquareState.yellow
        : Connect4SquareState.red;

    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        // Simulate the opponent's move
        final simulatedBoard = board.map((row) => List<Connect4SquareState>.from(row)).toList();
        Connect4GameLogic.applyMove(simulatedBoard, col, opponentChipColor);

        // Check if this move would let the opponent win
        if (Connect4GameLogic.getWinner(simulatedBoard) == opponentChipColor) {
          return GenericResult<int>.success(col); // Block the opponent's winning move
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

    if (legalColumns.isEmpty) {
      return GenericResult<int>.failure(ResultErrorCode.invalidState); // No legal moves available
    }

    return GenericResult<int>.success(legalColumns[Random().nextInt(legalColumns.length)]);
  }
}