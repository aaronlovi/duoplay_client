import 'dart:math';

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/models/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class Connect4IntermediateEngine extends Connect4EngineContract {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    TurnBasedGameBoard board = currentState.board;
    TurnBasedGameCellState chipColor = currentState.currentPlayer;

    // Check for a winning move
    // Iterate through each column to find a winning move
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      int row = 0;
      int index = row * Connect4GameLogic.columns + col;
      if (!Connect4GameLogic.isLegalMove(board, index)) continue;

      final simulatedBoard = TurnBasedGameBoard.copy(board);
      Connect4GameLogic.applyMove(simulatedBoard, index, chipColor);
      // Check if this move wins the game
      if (Connect4GameLogic.getWinner(simulatedBoard) == chipColor) {
        return GenericResult<int>.success(col); // Winning move found
      }
    }

    // Check for a blocking move
    final opponentChipColor = chipColor.getOpponent();

    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      int row = 0;
      int index = row * Connect4GameLogic.columns + col;
      if (!Connect4GameLogic.isLegalMove(board, index)) continue;

      final simulatedBoard = TurnBasedGameBoard.copy(board);
      Connect4GameLogic.applyMove(simulatedBoard, index, opponentChipColor);
      // Check if this move would let the opponent win
      if (Connect4GameLogic.getWinner(simulatedBoard) == opponentChipColor) {
        return GenericResult<int>.success(
          col,
        ); // Block the opponent's winning move
      }
    }

    // Otherwise, pick a random legal column
    final legalIndices = <int>[];
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      int row = 0;
      int index = row * Connect4GameLogic.columns + col;
      if (!Connect4GameLogic.isLegalMove(board, index)) continue;

      legalIndices.add(index);
    }

    if (legalIndices.isEmpty) {
      return GenericResult<int>.failure(
        ResultErrorCode.invalidState,
      ); // No legal moves available
    }

    return GenericResult<int>.success(
      legalIndices[Random().nextInt(legalIndices.length)],
    );
  }
}
