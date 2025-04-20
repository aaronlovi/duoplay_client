import 'dart:developer' as developer;

import 'package:duoplay/models/mini_max_result.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/utils/random.dart';

part '../connect_4/connect_4_beginner_engine.dart';
part '../connect_4/connect_4_expert_engine.dart';
part '../connect_4/connect_4_intermediate_engine.dart';
part '../tic_tac_toe/tic_tac_toe_beginner_engine.dart';
part '../tic_tac_toe/tic_tac_toe_expert_engine.dart';
part '../tic_tac_toe/tic_tac_toe_intermediate_engine.dart';

abstract class TurnBasedGameEngineContract {
  final TurnBasedGameLogic _gameLogic;

  TurnBasedGameEngineContract(TurnBasedGameLogic gameLogic)
    : _gameLogic = gameLogic;

  /// Returns the column index for the next move.
  GenericResult<int> getNextMove(TurnBasedGameState currentState);
}
