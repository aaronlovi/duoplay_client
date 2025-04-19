import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_outputs.dart';

class TTTNewBoardOutput implements TurnBasedGameFsmOutputBase {
  TicTacToeGameState gameState;

  TTTNewBoardOutput({required this.gameState});

  @override
  String toString() => 'TTTNewBoardOutput[gameState: $gameState]';
}

class TTTDoEngineMoveOutput implements TurnBasedGameFsmOutputBase {
  @override
  String toString() => 'TTTDoEngineMoveOutput[]';
}

class TTTErrorOutput implements TurnBasedGameFsmOutputBase {
  Result results;

  TTTErrorOutput({required this.results}) {
    if (results.isSuccess) {
      throw ArgumentError('Result cannot be successful for this type');
    }
  }

  @override
  String toString() => 'TTTErrorOutput[results: $results]';
}
