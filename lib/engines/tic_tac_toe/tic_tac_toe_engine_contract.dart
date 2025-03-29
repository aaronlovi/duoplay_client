import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';

abstract class TicTacToeEngineContract {
  GenericResult<int> getNextMove(TicTacToeGameState currentState);
}
