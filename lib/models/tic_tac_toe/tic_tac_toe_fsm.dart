import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'dart:developer'; // For logging with `log`

class TicTacToeFSM {
  TicTacToeGameState gameState;

  TicTacToeFSM() : gameState = TicTacToeGameState.initial();

  void update(
    int index,
    TicTacToeCellState player,
    List<TicTacToeOutput> output,
  ) {
    log('Update called with index: $index, player: $player');
    log('Current game state: $gameState');

    final res = gameState.makeMove(index, player);
    if (res.isFailure) {
      log('Move failed: ${res.errorCode}, Parameters: ${res.errorParameters}');
      output.add(TicTacToeErrorOutput(results: Result.fromFailure(res)));
      return;
    }

    TicTacToeGameState nextState = res.data!;
    log('Move successful. New game state: $nextState');

    output.add(TicTacToeNewBoardOutput(gameState: nextState));

    if (nextState.isGameOver) {
      log(
        'Game over. Winner: ${nextState.winner}, Is draw: ${nextState.isDraw}',
      );
      output.add(
        TicTacToeGameOverOutput(
          winner: nextState.winner,
          isDraw: nextState.isDraw,
        ),
      );
    }

    gameState = nextState;
    log('Game state updated.');
  }

  void reset() {
    log('Game reset.');
    gameState = TicTacToeGameState.initial();
  }
}
