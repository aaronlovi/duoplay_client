import 'dart:developer';

import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart'; // For logging with `log`

class TTTGameContainer extends TurnBasedGameUtils {
  final TTTFsm _fsm;

  TTTGameContainer({required TTTFsm fsm}) : _fsm = fsm;

  TurnBasedGameBoard get board => _fsm.board;
  bool get isPlayerXEngine => _fsm.isPlayerXEngine;
  bool get isPlayerOEngine => _fsm.isPlayerOEngine;
  bool get isHumanPlayerToMove => _fsm.isHumanPlayerToMove;
  TurnBasedGameCellState get humanPlayer => _fsm.humanPlayer;
  TurnBasedGameCellState get enginePlayer => _fsm.enginePlayer;
  TicTacToeGameState get gameState => _fsm.gameState;
  String get nextGameDifficulty => _fsm.nextGameDifficulty;

  TTTOutputContainer postInput(TurnBasedGameFsmInputBase inputs) {
    final outputs = <TurnBasedGameFsmOutputBase>[];
    final outputContainer = TTTOutputContainer(outputs: outputs);
    log('postInput(inputs: $inputs)');
    _fsm.update(inputs, outputContainer);
    for (var output in outputContainer.outputs) {
      log('postInput -> $output');
    }
    log('nextTimeOut: ${outputContainer.nextTimeout}');
    return outputContainer;
  }

  @override
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
