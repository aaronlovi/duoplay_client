import 'dart:developer' as developer;

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';

class Connect4ExpertEngine implements Connect4EngineContract {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    List<List<Connect4SquareState>> board = currentState.board;
    Connect4SquareState chipColor = currentState.currentPlayer;

    // Combine winning move check and center weighting evaluation into a single loop
    int bestScore = -1;
    int bestColumn = -1;

    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (!Connect4GameLogic.isLegalMove(board, col)) {
        continue;
      }

      // Simulate the move
      final simulatedBoard =
          board.map((row) => List<Connect4SquareState>.from(row)).toList();
      Connect4GameLogic.applyMove(simulatedBoard, col, chipColor);

      // Check if this move wins the game
      if (Connect4GameLogic.getWinner(simulatedBoard) == chipColor) {
        developer.log('[AI][Expert] Winning move found at column $col');
        return GenericResult<int>.success(col);
      }

      // Evaluate the board using the center weighting metric
      int score = _evaluateCenterWeighting(simulatedBoard, chipColor);

      if (score > bestScore) {
        bestScore = score;
        bestColumn = col;
      }
    }

    if (bestColumn != -1) {
      developer.log(
        '[AI][Expert] Best move found at column $bestColumn with score $bestScore',
      );
      return GenericResult<int>.success(bestColumn);
    }

    developer.log('[AI][Expert] No legal moves available');
    return GenericResult<int>.failure(ResultErrorCode.invalidState);
  }

  // Center weighting metric: prioritize moves closer to the center of the board
  int _evaluateCenterWeighting(List<List<Connect4SquareState>> board, Connect4SquareState chipColor) {
    final centerColumn = Connect4GameLogic.columns ~/ 2;
    int score = 0;

    for (int row = 0; row < Connect4GameLogic.rows; row++) {
      for (int col = 0; col < Connect4GameLogic.columns; col++) {
        if (board[row][col] == chipColor) {
          // Higher weight for chips closer to the center column
          score += Connect4GameLogic.columns - (col - centerColumn).abs();
        }
      }
    }

    return score;
  }
}
