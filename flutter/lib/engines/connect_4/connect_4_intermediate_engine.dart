part of '../turn_based_game/turn_based_game_engine_contract.dart';

class Connect4IntermediateEngine extends TurnBasedGameEngineContract {
  Connect4IntermediateEngine(super.gameLogic);

  @override
  GenericResult<int> getNextMove(TurnBasedGameState currentState) {
    TurnBasedGameBoard board = currentState.board;
    TurnBasedGameCellState chipColor = currentState.currentPlayer;

    // Check for a winning move
    // Iterate through each column to find a winning move
    for (int col = 0; col < _gameLogic.columns; col++) {
      int row = 0;
      int index = row * _gameLogic.columns + col;
      if (!_gameLogic.isLegalMove(board, index)) continue;

      final simulatedBoard = TurnBasedGameBoard.copy(board);
      _gameLogic.applyMove(simulatedBoard, index, chipColor);
      // Check if this move wins the game
      if (_gameLogic.getWinner(simulatedBoard) == chipColor) {
        return GenericResult<int>.success(col); // Winning move found
      }
    }

    // Check for a blocking move
    final opponentChipColor = chipColor.getOpponent();

    for (int col = 0; col < _gameLogic.columns; col++) {
      int row = 0;
      int index = row * _gameLogic.columns + col;
      if (!_gameLogic.isLegalMove(board, index)) continue;

      final simulatedBoard = TurnBasedGameBoard.copy(board);
      _gameLogic.applyMove(simulatedBoard, index, opponentChipColor);
      // Check if this move would let the opponent win
      if (_gameLogic.getWinner(simulatedBoard) == opponentChipColor) {
        return GenericResult<int>.success(
          col,
        ); // Block the opponent's winning move
      }
    }

    // Otherwise, pick a random legal column
    final legalIndices = <int>[];
    for (int col = 0; col < _gameLogic.columns; col++) {
      int row = 0;
      int index = row * _gameLogic.columns + col;
      if (!_gameLogic.isLegalMove(board, index)) continue;

      legalIndices.add(index);
    }

    if (legalIndices.isEmpty) {
      return GenericResult<int>.failure(
        ResultErrorCode.invalidState,
      ); // No legal moves available
    }

    return GenericResult<int>.success(
      legalIndices[random.nextInt(legalIndices.length)],
    );
  }
}
