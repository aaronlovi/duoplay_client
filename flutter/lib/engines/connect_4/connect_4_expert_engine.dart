import 'dart:developer' as developer;

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/models/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/mini_max_result.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class Connect4ExpertEngine implements Connect4EngineContract {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    TurnBasedGameBoard board = currentState.board;
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

    developer.log(
      '[AI][Expert] No legal moves available after iterative deepening',
    );
    return GenericResult<int>.failure(ResultErrorCode.invalidState);
  }

  // Center weighting metric: prioritize moves closer to the center of the board
  int evaluateCenterWeighting(
    TurnBasedGameBoard board,
    TurnBasedGameCellState chipColor,
  ) {
    final centerColumn = Connect4GameLogic.columns ~/ 2;
    int score = 0;

    for (int row = 0; row < Connect4GameLogic.rows; row++) {
      for (int col = 0; col < Connect4GameLogic.columns; col++) {
        int index = row * Connect4GameLogic.columns + col;
        if (board[index] == chipColor) {
          // Higher weight for chips closer to the center column
          score += Connect4GameLogic.columns - (col - centerColumn).abs();
        }
      }
    }

    return score;
  }

  // Potential connections metric: evaluate open sequences of 2 or 3 chips
  int evaluatePotentialConnections(
    TurnBasedGameBoard board,
    TurnBasedGameCellState chipColor,
  ) {
    int score = 0;

    // Helper function to count open sequences in a line
    int countOpenSequencesOnRow(TurnBasedGameBoard board, int rowIndex) {
      int count = 0;
      for (int i = 0; i <= Connect4GameLogic.columns - 4; i++) {
        int index0 = rowIndex * Connect4GameLogic.columns + i;
        int index1 = rowIndex * Connect4GameLogic.columns + i + 1;
        int index2 = rowIndex * Connect4GameLogic.columns + i + 2;
        int index3 = rowIndex * Connect4GameLogic.columns + i + 3;

        int numCellsOfChipColor =
            (board[index0] == chipColor ? 1 : 0) +
            (board[index1] == chipColor ? 1 : 0) +
            (board[index2] == chipColor ? 1 : 0) +
            (board[index3] == chipColor ? 1 : 0);
        int numEmptyCells = 4 - numCellsOfChipColor;

        if (numCellsOfChipColor >= 2 &&
            numEmptyCells == 4 - numCellsOfChipColor) {
          count++;
        }
      }
      return count;
    }

    int countOpenSequencesOnColumn(TurnBasedGameBoard board, int columnIndex) {
      int count = 0;
      for (int i = 0; i <= Connect4GameLogic.rows - 4; i++) {
        int index0 = i * Connect4GameLogic.columns + columnIndex;
        int index1 = (i + 1) * Connect4GameLogic.columns + columnIndex;
        int index2 = (i + 2) * Connect4GameLogic.columns + columnIndex;
        int index3 = (i + 3) * Connect4GameLogic.columns + columnIndex;
        int numCellsOfChipColor =
            board[index0] == chipColor
                ? 1
                : 0 +
                    (board[index1] == chipColor ? 1 : 0) +
                    (board[index2] == chipColor ? 1 : 0) +
                    (board[index3] == chipColor ? 1 : 0);
        int numEmptyCells = 4 - numCellsOfChipColor;
        if (numCellsOfChipColor >= 2 &&
            numEmptyCells == 4 - numCellsOfChipColor) {
          count++;
        }
      }
      return count;
    }

    int countOpenSequencesOnBottomLeftToTopRightDiagonal(
      TurnBasedGameBoard board,
      int rowIndex,
      int colIndex,
    ) {
      int count = 0;
      for (int i = 0; i <= 3; i++) {
        // Ensure indices are within bounds
        if (rowIndex + i + 3 < Connect4GameLogic.rows &&
            colIndex + i + 3 < Connect4GameLogic.columns) {
          int index0 =
              (rowIndex + i) * Connect4GameLogic.columns + (colIndex + i);
          int index1 =
              (rowIndex + i + 1) * Connect4GameLogic.columns +
              (colIndex + i + 1);
          int index2 =
              (rowIndex + i + 2) * Connect4GameLogic.columns +
              (colIndex + i + 2);
          int index3 =
              (rowIndex + i + 3) * Connect4GameLogic.columns +
              (colIndex + i + 3);

          int numCellsOfChipColor =
              (board[index0] == chipColor ? 1 : 0) +
              (board[index1] == chipColor ? 1 : 0) +
              (board[index2] == chipColor ? 1 : 0) +
              (board[index3] == chipColor ? 1 : 0);
          int numEmptyCells = 4 - numCellsOfChipColor;

          if (numCellsOfChipColor >= 2 &&
              numEmptyCells == 4 - numCellsOfChipColor) {
            count++;
          }
        }
      }
      return count;
    }

    int countOpenSequencesOnTopLeftToBottomRightDiagonal(
      TurnBasedGameBoard board,
      int rowIndex,
      int colIndex,
    ) {
      int count = 0;
      for (int i = 0; i <= 3; i++) {
        // Ensure indices are within bounds
        if (rowIndex - i - 3 >= 0 &&
            colIndex + i + 3 < Connect4GameLogic.columns) {
          int index0 =
              (rowIndex - i) * Connect4GameLogic.columns + (colIndex + i);
          int index1 =
              (rowIndex - i - 1) * Connect4GameLogic.columns +
              (colIndex + i + 1);
          int index2 =
              (rowIndex - i - 2) * Connect4GameLogic.columns +
              (colIndex + i + 2);
          int index3 =
              (rowIndex - i - 3) * Connect4GameLogic.columns +
              (colIndex + i + 3);

          int numCellsOfChipColor =
              (board[index0] == chipColor ? 1 : 0) +
              (board[index1] == chipColor ? 1 : 0) +
              (board[index2] == chipColor ? 1 : 0) +
              (board[index3] == chipColor ? 1 : 0);
          int numEmptyCells = 4 - numCellsOfChipColor;

          if (numCellsOfChipColor >= 2 &&
              numEmptyCells == 4 - numCellsOfChipColor) {
            count++;
          }
        }
      }
      return count;
    }

    // Check rows
    for (int row = 0; row < Connect4GameLogic.rows; row++) {
      score += countOpenSequencesOnRow(board, row);
    }

    // Check columns
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      score += countOpenSequencesOnColumn(board, col);
    }

    // Check diagonals (bottom-left to top-right)
    for (int row = 0; row < Connect4GameLogic.rows - 3; row++) {
      for (int col = 0; col < Connect4GameLogic.columns - 3; col++) {
        score += countOpenSequencesOnBottomLeftToTopRightDiagonal(
          board,
          row,
          col,
        );
      }
    }

    // Check diagonals (top-left to bottom-right)
    for (int row = 3; row < Connect4GameLogic.rows; row++) {
      for (int col = 0; col < Connect4GameLogic.columns - 3; col++) {
        score += countOpenSequencesOnTopLeftToBottomRightDiagonal(
          board,
          row,
          col,
        );
      }
    }

    return score;
  }

  // Minimax algorithm with alpha-beta pruning
  MinimaxResult minimaxWithAlphaBeta(
    TurnBasedGameBoard board,
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
      final simulatedBoard = TurnBasedGameBoard.copy(board);
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
  MinimaxResult iterativeDeepening(
    TurnBasedGameBoard board,
    TurnBasedGameCellState chipColor,
    int timeCapMs,
  ) {
    final stopwatch = Stopwatch()..start();
    MinimaxResult? bestResult;

    for (int depth = 1; stopwatch.elapsedMilliseconds < timeCapMs; depth++) {
      final result = minimaxWithAlphaBeta(
        board,
        depth,
        true,
        chipColor,
        -10000,
        10000,
      );
      bestResult = result;

      developer.log(
        '[AI][Expert] Iterative deepening depth $depth: move=${result.move}, score=${result.score}',
      );

      // Stop if a winning move is found
      if (result.score == 1000) {
        break;
      }
    }

    stopwatch.stop();

    // Log the total time taken
    developer.log(
      '[AI][Expert] Iterative deepening completed in ${stopwatch.elapsedMilliseconds} ms',
    );

    return bestResult ??
        MinimaxResult(
          move: null,
          score: -10000,
        ); // Return the best result found
  }
}
