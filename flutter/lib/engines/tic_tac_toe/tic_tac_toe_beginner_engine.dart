import 'dart:developer' as developer;

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/utils/random.dart';

class TTTBeginnerEngine implements TTTEngineContract {
  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    // Try to make an immediately winning move
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        final simulatedBoard = List<TTTCellState>.from(currentState.board);
        simulatedBoard[i] = currentState.currentPlayer;
        if (currentState.getWinner(simulatedBoard) ==
            currentState.currentPlayer) {
          developer.log('[AI][Beginner] Winning move found at $i');
          return GenericResult.success(i);
        }
      }
    }

    // Otherwise, make a random legal move
    final legalMoves = <int>[];
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        legalMoves.add(i);
      }
    }

    if (legalMoves.isNotEmpty) {
      final randomIndex = random.nextInt(legalMoves.length);
      developer.log(
        '[AI][Beginner] No winning move, picking random move at ${legalMoves[randomIndex]}',
      );
      return GenericResult.success(legalMoves[randomIndex]);
    }

    developer.log('[AI][Beginner] No legal moves available');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}
