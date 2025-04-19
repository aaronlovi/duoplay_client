import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class Connect4GameUtils extends TurnBasedGameUtils {
  @override
  String cellStateToShortString(TurnBasedGameCellState state) {
    switch (state) {
      case TurnBasedGameCellState.empty:
        return 'empty';
      case TurnBasedGameCellState.player1:
        return 'red';
      case TurnBasedGameCellState.player2:
        return 'yellow';
    }
  }
}
