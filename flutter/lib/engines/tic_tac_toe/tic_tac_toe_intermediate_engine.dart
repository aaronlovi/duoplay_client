part of 'tic_tac_toe_engine_contract.dart';

class TTTIntermediateEngine extends TTTEngineContract {
  TTTIntermediateEngine(super.gameLogic);

  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    // Try to make an immediately winning move
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TurnBasedGameCellState.empty) {
        final simulatedBoard = TurnBasedGameBoard.copy(currentState.board);
        simulatedBoard[i] = currentState.currentPlayer;
        if (currentState.getWinner(simulatedBoard) ==
            currentState.currentPlayer) {
          developer.log('[AI][Intermediate] Winning move found at $i');
          return GenericResult.success(i);
        }
      }
    }

    // Try to block opponent's immediately winning move
    final opponent = currentState.currentPlayer.getOpponent();
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TurnBasedGameCellState.empty) {
        final simulatedBoard = TurnBasedGameBoard.copy(currentState.board);
        simulatedBoard[i] = opponent;
        if (currentState.getWinner(simulatedBoard) == opponent) {
          developer.log('[AI][Intermediate] Blocking opponent win at $i');
          return GenericResult.success(i);
        }
      }
    }

    // Otherwise, make a random legal move
    final legalMoves = <int>[];
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TurnBasedGameCellState.empty) {
        legalMoves.add(i);
      }
    }

    if (legalMoves.isNotEmpty) {
      final randomIndex = random.nextInt(legalMoves.length);
      developer.log(
        '[AI][Intermediate] No win/block, picking random move at ${legalMoves[randomIndex]}',
      );
      return GenericResult.success(legalMoves[randomIndex]);
    }

    developer.log('[AI][Intermediate] No legal moves available');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}
