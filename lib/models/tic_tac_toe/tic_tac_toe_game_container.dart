import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_inputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart';
import 'dart:developer'; // For logging with `log`

class TicTacToeGameContainer {
  final TicTacToeFSM _fsm;

  TicTacToeGameContainer({required TicTacToeFSM fsm}) : _fsm = fsm;

  List<TicTacToeCellState> get board => _fsm.board;
  bool get isPlayerXEngine => _fsm.isPlayerXEngine;
  bool get isPlayerOEngine => _fsm.isPlayerOEngine;
  bool get isHumanPlayerToMove => _fsm.isHumanPlayerToMove;
  TicTacToeCellState get humanPlayer => _fsm.humanPlayer;
  TicTacToeCellState get enginePlayer => _fsm.enginePlayer;
  TicTacToeGameState get gameState => _fsm.gameState;

  TicTacToeOutputContainer postInput(TicTacToeInputBase inputs) {
    final outputs = <TTTOutputBase>[];
    final outputContainer = TicTacToeOutputContainer(outputs: outputs);
    log('postInput(inputs: $inputs)');
    _fsm.update(inputs, outputContainer);
    for (var output in outputContainer.outputs) {
      log('postInput -> $output');
    }
    log('nextTimeOut: ${outputContainer.nextTimeout}');
    return outputContainer;
  }
}
