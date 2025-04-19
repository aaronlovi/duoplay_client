import 'dart:developer' as developer;

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/mini_max_result.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class Connect4ExpertEngine implements Connect4EngineContract {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    List<List<TurnBasedGameCellState>> board = currentState.board;
    TurnBasedGameCellState chipColor = currentState.currentPlayer;

    // Use iterative deepening as the primary decision-making mechanism
    const timeCapMs = 500; // Set the time cap for iterative deepening
    final iterativeResult = iterativeDeepening(board, chipColor, timeCapMs);

    if (iterativeResult.move != null) {
      developer.log(
        '[AI][Expert] Iterative deepening selected column ${iterativeResult.move} with score ${iterativeResult.score}',
      );
      return GenericResult<int>.success(iterativeResult.move!);
    }

    developer.log('[AI][Expert] No legal moves available after iterative deepening');
    return GenericResult<int>.failure(ResultErrorCode.invalidState);
  }

  // Center weighting metric: prioritize moves closer to the center of the board
  int evaluateCenterWeighting(
    List<List<TurnBasedGameCellState>> board,
    TurnBasedGameCellState chipColor,
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
    List<List<TurnBasedGameCellState>> board,
    TurnBasedGameCellState chipColor,
  ) {
    int score = 0;

    // Helper function to count open sequences in a line
    int countOpenSequences(List<TurnBasedGameCellState> line) {
      int count = 0;
      for (int i = 0; i <= line.length - 4; i++) {
        final window = line.sublist(i, i + 4);
        if (window.where((cell) => cell == chipColor).length >= 2 &&
            window.where((cell) => cell == TurnBasedGameCellState.empty).length ==
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

  // Minimax algorithm with alpha-beta pruning
  MinimaxResult minimaxWithAlphaBeta(
    List<List<TurnBasedGameCellState>> board,
    int remainingDepth,
    bool isMaximizing,
    TurnBasedGameCellState chipColor,
    int alpha,
    int beta,
  ) {
    // Base case: check for terminal states (win, loss, draw) or depth limit
    final winner = Connect4GameLogic.getWinner(board);
    if (winner != TurnBasedGameCellState.empty) {
      if (winner == chipColor) {
        return MinimaxResult(
          move: null,
          score: 1000,
        ); // High positive score for a win
      } else {
        return MinimaxResult(
          move: null,
          score: -1000,
        ); // High negative score for a loss
      }
    }
    if (remainingDepth == 0 || Connect4GameLogic.isDraw(board)) {
      final score =
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
      final simulatedBoard =
          board.map((row) => List<TurnBasedGameCellState>.from(row)).toList();
      Connect4GameLogic.applyMove(simulatedBoard, col, currentChipColor);

      // Recursive call with alpha-beta pruning
      final result = minimaxWithAlphaBeta(
        simulatedBoard,
        remainingDepth - 1,
        !isMaximizing,
        chipColor,
        alpha,
        beta,
      );

      if (isMaximizing) {
        if (result.score > bestEval) {
          bestEval = result.score;
          bestMove = col;
        }
        alpha = alpha > bestEval ? alpha : bestEval;
      } else {
        if (result.score < bestEval) {
          bestEval = result.score;
          bestMove = col;
        }
        beta = beta < bestEval ? beta : bestEval;
      }

      // Prune branches
      if (beta <= alpha) break; // Beta cut-off
    }

    return MinimaxResult(move: bestMove, score: bestEval);
  }

  // Iterative deepening logic with a time cap
  MinimaxResult iterativeDeepening(List<List<TurnBasedGameCellState>> board, TurnBasedGameCellState chipColor, int timeCapMs) {
    final stopwatch = Stopwatch()..start();
    MinimaxResult? bestResult;

    for (int depth = 1; stopwatch.elapsedMilliseconds < timeCapMs; depth++) {
      final result = minimaxWithAlphaBeta(board, depth, true, chipColor, -10000, 10000);
      bestResult = result;

      developer.log('[AI][Expert] Iterative deepening depth $depth: move=${result.move}, score=${result.score}');

      // Stop if a winning move is found
      if (result.score == 1000) {
        break;
      }
    }

    stopwatch.stop();

    // Log the total time taken
    developer.log('[AI][Expert] Iterative deepening completed in ${stopwatch.elapsedMilliseconds} ms');

    return bestResult ?? MinimaxResult(move: null, score: -10000); // Return the best result found
  }
}
