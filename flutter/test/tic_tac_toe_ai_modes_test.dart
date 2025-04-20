import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_beginner_engine.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_expert_engine.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_intermediate_engine.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_logic.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicTacToe AI difficulty modes', () {
    test('Beginner: makes winning move if available, otherwise random', () {
      final config = TurnBasedGameConfiguration(
        enginePlayer: TurnBasedGameCellState.player1,
        betweenGamesWaitTime: Duration(seconds: 1),
        difficulty: 'beginner',
      );
      final engine = TTTBeginnerEngine();
      final boardString = '''
      X _ X
      O O _
      _ _ _
''';
      TurnBasedGameBoard board = TTTGameLogic.parseBoard(boardString);

      final state = TicTacToeGameState(
        board,
        TurnBasedGameCellState.player1,
        TurnBasedGameCellState.empty,
        2,
        2,
        DateTime.now().toUtc(),
        config,
        config.difficulty,
      );
      final move = engine.getNextMove(state);
      // X can win by playing at index 1
      expect(move.value, 1);
    });

    test('Intermediate: blocks opponent win if possible', () {
      final config = TurnBasedGameConfiguration(
        enginePlayer: TurnBasedGameCellState.player2,
        betweenGamesWaitTime: Duration(seconds: 1),
        difficulty: 'intermediate',
      );
      final engine = TTTIntermediateEngine();
      final boardString = '''
      X X _
      O _ _
      _ _ _
''';
      TurnBasedGameBoard board = TTTGameLogic.parseBoard(boardString);

      final state = TicTacToeGameState(
        board,
        TurnBasedGameCellState.player2,
        TurnBasedGameCellState.empty,
        2,
        1,
        DateTime.now().toUtc(),
        config,
        config.difficulty,
      );
      final move = engine.getNextMove(state);
      // O should block X at index 2
      expect(move.value, 2);
    });

    test('Expert: always plays perfect (center if available)', () {
      final config = TurnBasedGameConfiguration(
        enginePlayer: TurnBasedGameCellState.player1,
        betweenGamesWaitTime: Duration(seconds: 1),
        difficulty: 'expert',
      );
      final engine = TTTExpertEngine();

      // Empty board, X to move
      final state = TicTacToeGameState(
        TurnBasedGameBoard(TTTGameLogic.rows, TTTGameLogic.columns),
        TurnBasedGameCellState.player1,
        TurnBasedGameCellState.empty,
        0,
        0,
        DateTime.now().toUtc(),
        config,
        config.difficulty,
      );
      final move = engine.getNextMove(state);
      // Perfect play: X should take center if available
      expect(move.value, 4);
    });

    test(
      'Expert: O does not play upper-middle after X picks upper-left (should not play a losing move)',
      () {
        final config = TurnBasedGameConfiguration(
          enginePlayer: TurnBasedGameCellState.player2,
          betweenGamesWaitTime: Duration(seconds: 1),
          difficulty: 'expert',
        );
        final engine = TTTExpertEngine();

        // O to move. The only non-losing moves are corners or edge (not center or edge-middle).
        final boardString = '''
        X _ _
        _ _ _
        _ _ _
''';
        final board = TTTGameLogic.parseBoard(boardString);

        final state = TicTacToeGameState(
          board,
          TurnBasedGameCellState.player2,
          TurnBasedGameCellState.empty,
          1,
          0,
          DateTime.now().toUtc(),
          config,
          config.difficulty,
        );
        final move = engine.getNextMove(state);
        // O should NOT play edge (1, 3, 5, 7) as first move after X picks a corner
        expect(
          [1, 3, 5, 7].contains(move.value),
          isFalse,
          reason:
              'Expert O should not play a losing move after X picks a corner',
        );
      },
    );
  });
}
