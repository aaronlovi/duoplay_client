import 'dart:developer' as developer;

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/mini_max_result.dart';
import 'package:duoplay/models/result.dart';

class Connect4ExpertEngine implements Connect4EngineContract {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    List<List<Connect4SquareState>> board = currentState.board;
    Connect4SquareState chipColor = currentState.currentPlayer;

    // Use minimax as the primary decision-making mechanism
    const depthLimit = 4; // Set a fixed depth limit for minimax
    final minimaxResult = minimax(board, depthLimit, true, chipColor);

    if (minimaxResult.move != null) {
      developer.log('[AI][Expert] Minimax selected column ${minimaxResult.move} with score ${minimaxResult.score}');
      return GenericResult<int>.success(minimaxResult.move!);
    }

    developer.log('[AI][Expert] No legal moves available after minimax');
    return GenericResult<int>.failure(ResultErrorCode.invalidState);
  }

  // Center weighting metric: prioritize moves closer to the center of the board
  int evaluateCenterWeighting(
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
  int evaluatePotentialConnections(
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

  MinimaxResult minimax(
    List<List<Connect4SquareState>> board,
    int remainingDepth,
    bool isMaximizing,
    Connect4SquareState chipColor,
  ) {
    // Base case: check for terminal states (win, loss, draw) or depth limit
    final Connect4SquareState winner = Connect4GameLogic.getWinner(board);
    if (winner != Connect4SquareState.empty) {
      return winner == chipColor
          ? MinimaxResult(move: null, score: 1000)
          : MinimaxResult(move: null, score: -1000);
    }
    if (remainingDepth == 0 || Connect4GameLogic.isDraw(board)) {
      final int score =
          evaluateCenterWeighting(board, chipColor) +
          evaluatePotentialConnections(board, chipColor); // Static evaluation
      return MinimaxResult(move: null, score: score);
    }

    int bestEval = isMaximizing ? -10000 : 10000;
    int? bestMove;
    final currentChipColor = isMaximizing ? chipColor : chipColor.getOpponent();

    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (!Connect4GameLogic.isLegalMove(board, col)) continue;

      // Simulate the move
      final List<List<Connect4SquareState>> simulatedBoard =
          board.map((row) => List<Connect4SquareState>.from(row)).toList();
      Connect4GameLogic.applyMove(simulatedBoard, col, currentChipColor);

      // Recursive call
      final MinimaxResult result = minimax(
        simulatedBoard,
        remainingDepth - 1,
        !isMaximizing,
        chipColor,
      );

      // Prune branches that are better than the best found so far
      if (isMaximizing && result.score <= bestEval) continue;
      if (!isMaximizing && result.score >= bestEval) continue;

      bestEval = result.score;
      bestMove = col;
    }

    return MinimaxResult(move: bestMove, score: bestEval);
  }
}
