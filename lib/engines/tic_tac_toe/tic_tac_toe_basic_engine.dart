import 'dart:math';

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';

class TicTacToeBasicEngine implements TicTacToeEngineContract {
  final random = Random();

  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    final blockingMoves = <int>[];
    final otherMoves = <int>[];
    final playerToMove = currentState.currentPlayer;
    final otherPlayer = playerToMove.getOpponent();
    final currentBoard = currentState.board;

    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] != TicTacToeCellState.empty) continue;

      for (var combination in TicTacToeConstants.winningCombinations) {
        if (!combination.contains(i)) continue;

        int numSquaresOccupiedByCurrentPlayer = 0;
        int numSquaresOccupiedByOpponent = 0;
        for (var index in combination) {
          if (currentBoard[index] == playerToMove) {
            ++numSquaresOccupiedByCurrentPlayer;
          } else if (currentBoard[index] == otherPlayer) {
            ++numSquaresOccupiedByOpponent;
          }
        }
        if (numSquaresOccupiedByCurrentPlayer == 2) {
          // Two squares occupied by player and one empty square,
          // So this move is a win
          return GenericResult.success(i);
        } else if (numSquaresOccupiedByOpponent == 2) {
          // Two squares occupied by opponent and one empty square,
          // So this is a blocking move
          blockingMoves.add(i);
        } else {
          otherMoves.add(i);
        }
      }
    }

    if (blockingMoves.isNotEmpty) {
      final randomIndex = random.nextInt(blockingMoves.length);
      return GenericResult.success(blockingMoves[randomIndex]);
    }

    if (otherMoves.isNotEmpty) {
      final randomIndex = random.nextInt(otherMoves.length);
      return GenericResult.success(otherMoves[randomIndex]);
    }

    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}
