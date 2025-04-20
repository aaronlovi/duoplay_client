import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';

class TTTGameContainer extends TurnBasedGameContainer {
  TTTGameContainer({required super.fsm});

  String cellStateToShortString(TurnBasedGameCellState state) {
    switch (state) {
      case TurnBasedGameCellState.empty:
        return 'empty';
      case TurnBasedGameCellState.player1:
        return 'X';
      case TurnBasedGameCellState.player2:
        return 'O';
    }
  }
}
