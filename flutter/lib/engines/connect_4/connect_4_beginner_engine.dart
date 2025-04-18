import 'dart:developer' as developer;

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/utils/random.dart';

class Connect4BeginnerEngine implements Connect4EngineContract {
  @override
  GenericResult<int> getNextMove(Connect4GameState currentState) {
    List<List<Connect4SquareState>> board = currentState.board;
    Connect4SquareState chipColor = currentState.currentPlayer;

    // Check for a winning move
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
        // Simulate the move
        final simulatedBoard =
            board.map((row) => List<Connect4SquareState>.from(row)).toList();
        Connect4GameLogic.applyMove(simulatedBoard, col, chipColor);

        // Check if this move wins the game
        if (Connect4GameLogic.getWinner(simulatedBoard) == chipColor) {
          return GenericResult<int>.success(col);
        }
      }
    }

    // Otherwise, pick a random legal column
    final legalColumns = <int>[];
    for (int col = 0; col < Connect4GameLogic.columns; col++) {
      if (Connect4GameLogic.isLegalMove(board, col)) {
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
