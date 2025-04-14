import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';

abstract class TTTEngineContract {
  GenericResult<int> getNextMove(TicTacToeGameState currentState);
}
