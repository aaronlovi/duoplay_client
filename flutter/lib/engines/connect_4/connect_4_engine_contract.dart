import 'dart:developer' as developer;
import 'dart:math';

import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/mini_max_result.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/utils/random.dart';

part 'connect_4_beginner_engine.dart';
part 'connect_4_intermediate_engine.dart';
part 'connect_4_expert_engine.dart';

abstract class Connect4EngineContract {
  final TurnBasedGameLogic _gameLogic;

  Connect4EngineContract(TurnBasedGameLogic gameLogic) : _gameLogic = gameLogic;

  /// Returns the column index for the next move.
  GenericResult<int> getNextMove(Connect4GameState currentState);
}
