import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_inputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart';
import 'dart:developer'; // For logging with `log`

class TTTGameContainer {
  final TTTFsm _fsm;

  TTTGameContainer({required TTTFsm fsm}) : _fsm = fsm;

  List<TTTCellState> get board => _fsm.board;
  bool get isPlayerXEngine => _fsm.isPlayerXEngine;
  bool get isPlayerOEngine => _fsm.isPlayerOEngine;
  bool get isHumanPlayerToMove => _fsm.isHumanPlayerToMove;
  TTTCellState get humanPlayer => _fsm.humanPlayer;
  TTTCellState get enginePlayer => _fsm.enginePlayer;
  TicTacToeGameState get gameState => _fsm.gameState;

  void updateEngineDifficulty(String newDifficulty) {
    _fsm.updateEngineDifficulty(newDifficulty);
  }

  TTTOutputContainer postInput(TTTInputBase inputs) {
    final outputs = <TTTOutputBase>[];
    final outputContainer = TTTOutputContainer(outputs: outputs);
    log('postInput(inputs: $inputs)');
    _fsm.update(inputs, outputContainer);
    for (var output in outputContainer.outputs) {
      log('postInput -> $output');
    }
    log('nextTimeOut: ${outputContainer.nextTimeout}');
    return outputContainer;
  }
}
