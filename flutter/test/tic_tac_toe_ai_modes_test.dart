import 'package:flutter_test/flutter_test.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_basic_engine.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';

void main() {
  group('TicTacToe AI difficulty modes', () {
    test('Beginner: makes winning move if available, otherwise random', () {
      final config = TTTGameConfiguration(
        enginePlayer: TTTCellState.x,
        betweenGamesWaitTime: Duration(seconds: 1),
        difficulty: 'beginner',
      );
      final engine = TTTBeginnerEngine();
      // X _ X
      // O O _
      // _ _ _
      final state = TicTacToeGameState(
        [
          TTTCellState.x,
          TTTCellState.empty,
          TTTCellState.x,
          TTTCellState.o,
          TTTCellState.o,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
        ],
        TTTCellState.x,
        TTTCellState.empty,
        2,
        2,
        DateTime.now().toUtc(),
        config,
      );
      final move = engine.getNextMove(state);
      // X can win by playing at index 1
      expect(move.value, 1);
    });

    test('Intermediate: blocks opponent win if possible', () {
      final config = TTTGameConfiguration(
        enginePlayer: TTTCellState.o,
        betweenGamesWaitTime: Duration(seconds: 1),
        difficulty: 'intermediate',
      );
      final engine = TTTIntermediateEngine();
      // X X _
      // O _ _
      // _ _ _
      final state = TicTacToeGameState(
        [
          TTTCellState.x,
          TTTCellState.x,
          TTTCellState.empty,
          TTTCellState.o,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
        ],
        TTTCellState.o,
        TTTCellState.empty,
        2,
        1,
        DateTime.now().toUtc(),
        config,
      );
      final move = engine.getNextMove(state);
      // O should block X at index 2
      expect(move.value, 2);
    });

    test('Expert: always plays perfect (center if available)', () {
      final config = TTTGameConfiguration(
        enginePlayer: TTTCellState.x,
        betweenGamesWaitTime: Duration(seconds: 1),
        difficulty: 'expert',
      );
      final engine = TTTExpertEngine();
      // Empty board, X to move
      final state = TicTacToeGameState(
        [
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
          TTTCellState.empty,
        ],
        TTTCellState.x,
        TTTCellState.empty,
        0,
        0,
        DateTime.now().toUtc(),
        config,
      );
      final move = engine.getNextMove(state);
      // Perfect play: X should take center if available
      expect(move.value, 4);
    });

    test(
      'Expert (O): does NOT pick center if it is a losing move after X picks a corner',
      () {
        final config = TTTGameConfiguration(
          enginePlayer: TTTCellState.o,
          betweenGamesWaitTime: Duration(seconds: 1),
          difficulty: 'expert',
        );
        final engine = TTTExpertEngine();
        // Board setup:
        // X _ _
        // _ _ _
        // _ _ _
        // X is first, picks a corner (0). O to move.
        final state = TicTacToeGameState(
          [
            TTTCellState.x,
            TTTCellState.empty,
            TTTCellState.empty,
            TTTCellState.empty,
            TTTCellState.empty,
            TTTCellState.empty,
            TTTCellState.empty,
            TTTCellState.empty,
            TTTCellState.empty,
          ],
          TTTCellState.o,
          TTTCellState.empty,
          1,
          0,
          DateTime.now().toUtc(),
          config,
        );
        final move = engine.getNextMove(state);
        // The expert engine should NOT pick the center (4) if it leads to a loss
        expect(
          move.value != 4,
          true,
          reason:
              'Expert O should avoid losing center move after X picks a corner',
        );
      },
    );
  });
}
