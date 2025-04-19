import 'dart:developer' as developer;

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/mini_max_result.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class TTTExpertEngine implements TTTEngineContract {
  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    // Always use minimax from the perspective of the engine player
    final bestMove =
        _minimax(
          currentState,
          currentState.configuration.enginePlayer,
          true,
        ).move;
    if (bestMove != null) {
      developer.log('[AI][Expert] Minimax selected move $bestMove');
      return GenericResult.success(bestMove);
    }

    developer.log('[AI][Expert] No valid move found by minimax');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }

  MinimaxResult _minimax(
    TicTacToeGameState state,
    TurnBasedGameCellState rootPlayer, // Always optimize for the engine player
    bool isMaximizing,
  ) {
    if (state.isGameOver) {
      int score;
      if (state.winner == rootPlayer) {
        score = 10;
      } else if (state.winner == rootPlayer.getOpponent()) {
        score = -10;
      } else {
        score = 0;
      }
      return MinimaxResult(score: score);
    }

    final moves = <MinimaxResult>[];
    for (int i = 0; i < state.board.length; ++i) {
      if (state.board[i] != TurnBasedGameCellState.empty) continue;
      final newState = _simulateMove(state, i, state.currentPlayer);
      final result = _minimax(newState, rootPlayer, !isMaximizing);

      int score = result.score;

      // Give a small bonus if the engine is picking the center square
      if (isMaximizing && rootPlayer == state.currentPlayer && i == 4) {
        score += 1;
      }

      moves.add(MinimaxResult(move: i, score: score));
    }

    if (isMaximizing) {
      return moves.reduce((a, b) => a.score > b.score ? a : b);
    } else {
      return moves.reduce((a, b) => a.score < b.score ? a : b);
    }
  }

  TicTacToeGameState _simulateMove(
    TicTacToeGameState state,
    int index,
    TurnBasedGameCellState player,
  ) {
    final newBoard = List<TurnBasedGameCellState>.from(state.board);
    newBoard[index] = player;
    return TicTacToeGameState(
      newBoard,
      player.getOpponent(),
      state.getWinner(newBoard),
      player == TurnBasedGameCellState.player1 ? state.numberOfX + 1 : state.numberOfX,
      player == TurnBasedGameCellState.player2 ? state.numberOfO + 1 : state.numberOfO,
      state.nowUtc,
      state.configuration,
      state.configuration.difficulty,
    );
  }
}
