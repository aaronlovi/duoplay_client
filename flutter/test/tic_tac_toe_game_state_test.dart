import 'package:flutter_test/flutter_test.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_enums.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';

void main() {
  group('TicTacToeGameState edge cases', () {
    late TTTGameConfiguration config;
    setUp(() {
      config = TTTGameConfiguration(
        enginePlayer: TTTCellState.o,
        betweenGamesWaitTime: Duration(seconds: 7),
      );
    });

    test('Invalid move: out of bounds', () {
      final state = TicTacToeGameState.initial(config);
      final result = state.makeMove(-1, TTTCellState.x);
      expect(result.isFailure, true);
      final result2 = state.makeMove(9, TTTCellState.x);
      expect(result2.isFailure, true);
    });

    test('Invalid move: cell already occupied', () {
      final state = TicTacToeGameState.initial(config);
      state.makeMove(0, TTTCellState.x);
      final result = state.makeMove(0, TTTCellState.o);
      expect(result.isFailure, true);
    });

    test('Draw: board full, no winner', () {
      // X O X
      // X O O
      // O X X
      final state = TicTacToeGameState(
        [
          TTTCellState.x,
          TTTCellState.o,
          TTTCellState.x,
          TTTCellState.x,
          TTTCellState.o,
          TTTCellState.o,
          TTTCellState.o,
          TTTCellState.x,
          TTTCellState.x,
        ],
        TTTCellState.o,
        TTTCellState.empty,
        5,
        4,
        DateTime.now().toUtc(),
        config,
        config.difficulty,
      );
      expect(state.isDraw, true);
      expect(state.hasWinner, false);
    });

    test('Simultaneous win/draw: last move wins', () {
      // X O O
      // X O O
      // _ X X
      // X moves at index 6 to win (middle column)
      final state = TicTacToeGameState(
        [
          TTTCellState.x,
          TTTCellState.o,
          TTTCellState.o,
          TTTCellState.x,
          TTTCellState.o,
          TTTCellState.o,
          TTTCellState.empty,
          TTTCellState.x,
          TTTCellState.x,
        ],
        TTTCellState.x, // X's turn
        TTTCellState.empty,
        4, // numberOfX
        4, // numberOfO
        DateTime.now().toUtc(),
        config,
        config.difficulty,
      );
      final result = state.makeMove(6, TTTCellState.x);
      expect(result.isSuccess, true);
      expect(state.hasWinner, true);
      expect(state.isDraw, false);
      expect(state.winner, TTTCellState.x);
    });
  });
}
