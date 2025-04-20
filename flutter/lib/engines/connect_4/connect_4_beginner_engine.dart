part of '../turn_based_game/turn_based_game_engine_contract.dart';

class Connect4BeginnerEngine extends TurnBasedGameEngineContract {
  Connect4BeginnerEngine(super.gameLogic);

  @override
  GenericResult<int> getNextMove(TurnBasedGameState currentState) {
    TurnBasedGameBoard board = currentState.board;
    TurnBasedGameCellState chipColor = currentState.currentPlayer;

    // Check for a winning move
    for (int col = 0; col < _gameLogic.columns; col++) {
      if (_gameLogic.isLegalMove(board, col)) {
        // Simulate the move
        final simulatedBoard = TurnBasedGameBoard.copy(board);
        _gameLogic.applyMove(simulatedBoard, col, chipColor);

        // Check if this move wins the game
        if (_gameLogic.getWinner(simulatedBoard) == chipColor) {
          return GenericResult<int>.success(col);
        }
      }
    }

    // Otherwise, pick a random legal column
    final legalColumns = <int>[];
    for (int col = 0; col < _gameLogic.columns; col++) {
      if (_gameLogic.isLegalMove(board, col)) {
        legalColumns.add(col);
      }
    }

    if (legalColumns.isNotEmpty) {
      final randomColumn = random.nextInt(legalColumns.length);
      developer.log(
        '[AI][Beginner] No winning move, picking random move at ${legalColumns[randomColumn]}',
      );
      return GenericResult<int>.success(legalColumns[randomColumn]);
    }

    developer.log('[AI][Beginner] No legal moves available');
    return GenericResult<int>.failure(ResultErrorCode.invalidState);
  }
}
