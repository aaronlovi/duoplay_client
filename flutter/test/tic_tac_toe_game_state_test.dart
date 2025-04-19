import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicTacToeGameState edge cases', () {
    late TurnBasedGameConfiguration config;
    setUp(() {
      config = TurnBasedGameConfiguration(
        enginePlayer: TurnBasedGameCellState.player2,
        betweenGamesWaitTime: Duration(seconds: 7),
      );
    });

    test('Invalid move: out of bounds', () {
      final state = TicTacToeGameState.initial(config);
      final result = state.makeMove(-1, TurnBasedGameCellState.player1);
      expect(result.isFailure, true);
      final result2 = state.makeMove(9, TurnBasedGameCellState.player1);
      expect(result2.isFailure, true);
    });

    test('Invalid move: cell already occupied', () {
      final state = TicTacToeGameState.initial(config);
      state.makeMove(0, TurnBasedGameCellState.player1);
      final result = state.makeMove(0, TurnBasedGameCellState.player2);
      expect(result.isFailure, true);
    });

    test('Draw: board full, no winner', () {
      // X O X
      // X O O
      // O X X
      final state = TicTacToeGameState(
        [
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player1,
        ],
        TurnBasedGameCellState.player2,
        TurnBasedGameCellState.empty,
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
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.empty,
          TurnBasedGameCellState.player1,
          TurnBasedGameCellState.player1,
        ],
        TurnBasedGameCellState.player1, // X's turn
        TurnBasedGameCellState.empty,
        4, // numberOfX
        4, // numberOfO
        DateTime.now().toUtc(),
        config,
        config.difficulty,
      );
      final result = state.makeMove(6, TurnBasedGameCellState.player1);
      expect(result.isSuccess, true);
      expect(state.hasWinner, true);
      expect(state.isDraw, false);
      expect(state.winner, TurnBasedGameCellState.player1);
    });
  });
}
