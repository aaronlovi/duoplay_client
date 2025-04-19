import 'dart:math';

import 'package:duoplay/models/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

import 'connect_4_beginner_engine.dart';

class Connect4IntermediateEngine extends Connect4BeginnerEngine {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    List<List<TurnBasedGameCellState>> board = currentState.board;
    TurnBasedGameCellState chipColor = currentState.currentPlayer;

    // Check for a winning move
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        // Simulate the move
        final simulatedBoard = board.map((row) => List<TurnBasedGameCellState>.from(row)).toList();
        Connect4GameLogic.applyMove(simulatedBoard, col, chipColor);

        // Check if this move wins the game
        if (Connect4GameLogic.getWinner(simulatedBoard) == chipColor) {
          return GenericResult<int>.success(col);
        }
      }
    }

    // Check for a blocking move
    final opponentChipColor = chipColor.getOpponent();

    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        // Simulate the opponent's move
        final simulatedBoard = board.map((row) => List<TurnBasedGameCellState>.from(row)).toList();
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