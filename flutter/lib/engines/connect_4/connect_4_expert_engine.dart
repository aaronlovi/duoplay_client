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

    int bestScore = -1;
    int bestColumn = -1;
    int? blockingColumn;
    final opponentChipColor = chipColor.getOpponent();

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

      // Simulate the opponent's move
      final opponentSimulatedBoard =
          board.map((row) => List<Connect4SquareState>.from(row)).toList();
      Connect4GameLogic.applyMove(opponentSimulatedBoard, col, opponentChipColor);

      // Check if this move would let the opponent win
      if (Connect4GameLogic.getWinner(opponentSimulatedBoard) == opponentChipColor) {
        // Keep track of the most recent blocking column
        // If the opponent has multiple winning moves, we will block the last one
        developer.log('[AI][Expert] Blocking opponent win found at column $col');
        blockingColumn = col;
      }

      if (blockingColumn != null) {
        // If we found a blocking move, we can skip further evaluation
        continue;
      }
      
      // Evaluate the board using the center weighting and potential connections metrics
      int score = _evaluateCenterWeighting(simulatedBoard, chipColor) +
          _evaluatePotentialConnections(simulatedBoard, chipColor);

      if (score > bestScore) {
        bestScore = score;
        bestColumn = col;
      }
    }

    if (blockingColumn != null) {
      developer.log('[AI][Expert] Blocking opponent win at column $blockingColumn');
      return GenericResult<int>.success(blockingColumn);
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
  int _evaluateCenterWeighting(
    List<List<Connect4SquareState>> board,
    Connect4SquareState chipColor,
  ) {
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

  // Potential connections metric: evaluate open sequences of 2 or 3 chips
  int _evaluatePotentialConnections(
    List<List<Connect4SquareState>> board,
    Connect4SquareState chipColor,
  ) {
    int score = 0;

    // Helper function to count open sequences in a line
    int countOpenSequences(List<Connect4SquareState> line) {
      int count = 0;
      for (int i = 0; i <= line.length - 4; i++) {
        final window = line.sublist(i, i + 4);
        if (window.where((cell) => cell == chipColor).length >= 2 &&
            window.where((cell) => cell == Connect4SquareState.empty).length ==
                4 - window.where((cell) => cell == chipColor).length) {
          count++;
        }
      }
      return count;
    }

    // Check rows
    for (int row = 0; row < Connect4GameLogic.rows; row++) {
      score += countOpenSequences(board[row]);
    }

    // Check columns
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      final column = [
        for (int row = 0; row < Connect4GameLogic.rows; row++) board[row][col],
      ];
      score += countOpenSequences(column);
    }

    // Check diagonals (bottom-left to top-right)
    for (int row = 0; row < Connect4GameLogic.rows - 3; row++) {
      for (int col = 0; col < Connect4GameLogic.columns - 3; col++) {
        final diagonal = [
          board[row][col],
          board[row + 1][col + 1],
          board[row + 2][col + 2],
          board[row + 3][col + 3],
        ];
        score += countOpenSequences(diagonal);
      }
    }

    // Check diagonals (top-left to bottom-right)
    for (int row = 3; row < Connect4GameLogic.rows; row++) {
      for (int col = 0; col < Connect4GameLogic.columns - 3; col++) {
        final diagonal = [
          board[row][col],
          board[row - 1][col + 1],
          board[row - 2][col + 2],
          board[row - 3][col + 3],
        ];
        score += countOpenSequences(diagonal);
      }
    }

    return score;
  }
}
