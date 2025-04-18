import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';

abstract class Connect4EngineContract {
  /// Returns the column index for the next move.
  GenericResult<int> getNextMove(Connect4GameState currentState);
}
