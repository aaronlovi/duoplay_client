import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_inputs.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_outputs.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/connect_4/connect_4_output_container.dart';
import 'dart:developer'; // For logging with `log`

class Connect4GameContainer {
  final Connect4FSM _fsm;

  Connect4GameContainer({required Connect4FSM fsm}) : _fsm = fsm;

  List<List<Connect4SquareState>> get board => _fsm.board;
  bool get isPlayerRedEngine => _fsm.isPlayerRedEngine;
  bool get isPlayerYellowEngine => _fsm.isPlayerYellowEngine;
  bool get isHumanPlayerToMove => _fsm.isHumanPlayerToMove;
  Connect4SquareState get humanPlayer => _fsm.humanPlayer;
  Connect4SquareState get enginePlayer => _fsm.enginePlayer;
  Connect4GameState get gameState => _fsm.gameState;
  String get nextGameDifficulty => _fsm.nextGameDifficulty;

  Connect4OutputContainer postInput(Connect4InputBase inputs) {
    final outputs = <Connect4OutputBase>[];
    final outputContainer = Connect4OutputContainer(outputs: outputs);
    log('postInput(inputs: $inputs)');
    _fsm.update(inputs, outputContainer);
    for (var output in outputContainer.outputs) {
      log('postInput -> $output');
    }
    log('nextTimeOut: ${outputContainer.nextTimeout}');
    return outputContainer;
  }
}