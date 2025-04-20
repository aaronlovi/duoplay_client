import 'dart:developer';

import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/models/turn_based_game_fsm.dart';

class Connect4GameContainer {
  final TurnBasedGameFsm _fsm;

  Connect4GameContainer({required TurnBasedGameFsm fsm}) : _fsm = fsm;

  TurnBasedGameBoard get board => _fsm.board;
  bool get isPlayerRedEngine => _fsm.isPlayer1Engine;
  bool get isPlayerYellowEngine => _fsm.isPlayer2Engine;
  bool get isHumanPlayerToMove => _fsm.isHumanPlayerToMove;
  TurnBasedGameCellState get humanPlayer => _fsm.humanPlayer;
  TurnBasedGameCellState get enginePlayer => _fsm.enginePlayer;
  TurnBasedGameState get gameState => _fsm.gameState;
  String get nextGameDifficulty => _fsm.nextGameDifficulty;

  TurnBasedGameOutputContainer postInput(TurnBasedGameFsmInputBase inputs) {
    final outputs = <TurnBasedGameFsmOutputBase>[];
    final outputContainer = TurnBasedGameOutputContainer(outputs: outputs);
    log('postInput(inputs: $inputs)');
    _fsm.update(inputs, outputContainer);
    for (var output in outputContainer.outputs) {
      log('postInput -> $output');
    }
    log('nextTimeOut: ${outputContainer.nextTimeout}');
    return outputContainer;
  }
}
