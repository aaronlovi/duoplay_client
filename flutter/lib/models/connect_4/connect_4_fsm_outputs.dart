import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';

class Connect4NewBoardOutput implements TurnBasedGameFsmOutputBase {
  Connect4GameState gameState;

  Connect4NewBoardOutput({required this.gameState});

  @override
  String toString() => 'Connect4NewBoardOutput[gameState: $gameState]';
}
