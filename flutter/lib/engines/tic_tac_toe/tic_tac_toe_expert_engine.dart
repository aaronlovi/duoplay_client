part of '../turn_based_game/turn_based_game_engine_contract.dart';

class TTTExpertEngine extends TurnBasedGameEngineContract {
  TTTExpertEngine(super.gameLogic);

  @override
  GenericResult<int> getNextMove(TurnBasedGameState currentState) {
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
    TurnBasedGameState state,
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

  TurnBasedGameState _simulateMove(
    TurnBasedGameState state,
    int index,
    TurnBasedGameCellState player,
  ) {
    final newBoard = TurnBasedGameBoard.copy(state.board);
    newBoard[index] = player;
    return TTTGameState(
      newBoard,
      _gameLogic,
      player.getOpponent(),
      _gameLogic.getWinner(newBoard),
      player == TurnBasedGameCellState.player1
          ? state.numberOfPlayer1 + 1
          : state.numberOfPlayer1,
      player == TurnBasedGameCellState.player2
          ? state.numberOfPlayer2 + 1
          : state.numberOfPlayer2,
      state.nowUtc,
      state.configuration,
      state.configuration.difficulty,
    );
  }
}
