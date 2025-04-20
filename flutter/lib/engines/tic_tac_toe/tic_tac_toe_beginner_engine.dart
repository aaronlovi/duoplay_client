part of 'tic_tac_toe_engine_contract.dart';

class TTTBeginnerEngine extends TTTEngineContract {
  TTTBeginnerEngine(super.gameLogic);

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
          developer.log('[AI][Beginner] Winning move found at $i');
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
        '[AI][Beginner] No winning move, picking random move at ${legalMoves[randomIndex]}',
      );
      return GenericResult.success(legalMoves[randomIndex]);
    }

    developer.log('[AI][Beginner] No legal moves available');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}
