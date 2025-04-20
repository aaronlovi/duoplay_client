import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Connect4ExpertEngine - Static Board Evaluator', () {
    final gameLogic = Connect4GameLogic();
    final engine = Connect4ExpertEngine(gameLogic);

    test('Center weighting metric prioritizes center columns', () {
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      board[5 * 7 + 3] =
          TurnBasedGameCellState.player1; // Place a chip in the center

      final score = engine.evaluateCenterWeighting(
        board,
        TurnBasedGameCellState.player1,
      );

      expect(score, greaterThan(0)); // Ensure center chip contributes to score
    });

    test('Potential connections metric identifies open sequences', () {
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      board[5 * 7 + 0] = TurnBasedGameCellState.player1;
      board[5 * 7 + 1] = TurnBasedGameCellState.player1;
      board[5 * 7 + 2] = TurnBasedGameCellState.empty;
      board[5 * 7 + 3] = TurnBasedGameCellState.empty;

      final score = engine.evaluatePotentialConnections(
        board,
        TurnBasedGameCellState.player1,
      );

      expect(
        score,
        greaterThan(0),
      ); // Ensure open sequences contribute to score
    });
  });

  group('Connect4ExpertEngine - Minimax with Alpha-Beta Pruning', () {
    final gameLogic = Connect4GameLogic();
    final engine = Connect4ExpertEngine(gameLogic);

    test('Alpha-beta pruning avoids unnecessary branches', () {
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      board[5 * 7 + 0] = TurnBasedGameCellState.player1;
      board[5 * 7 + 1] = TurnBasedGameCellState.player1;
      board[5 * 7 + 2] = TurnBasedGameCellState.player1;
      board[5 * 7 + 3] = TurnBasedGameCellState.empty; // Winning move

      final result = engine.minimaxWithAlphaBeta(
        board,
        4, // Depth limit
        true,
        TurnBasedGameCellState.player1,
        -10000,
        10000,
      );

      expect(result.move, equals(3)); // Ensure the winning move is selected
      expect(result.score, greaterThan(0)); // Positive score for a win
    });

    test('Alpha-beta pruning blocks opponent win', () {
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      board[5 * 7 + 0] = TurnBasedGameCellState.player2;
      board[5 * 7 + 1] = TurnBasedGameCellState.player2;
      board[5 * 7 + 2] = TurnBasedGameCellState.player2;
      board[5 * 7 + 3] = TurnBasedGameCellState.empty; // Blocking move

      final result = engine.minimaxWithAlphaBeta(
        board,
        4, // Depth limit
        true,
        TurnBasedGameCellState.player1,
        -10000,
        10000,
      );

      expect(result.move, equals(3)); // Ensure the blocking move is selected
      expect(result.score, lessThan(1000)); // Score should not indicate a win
    });
  });

  group('Connect4ExpertEngine - Iterative Deepening', () {
    final gameLogic = Connect4GameLogic();
    final engine = Connect4ExpertEngine(gameLogic);

    test('Iterative deepening respects time cap', () {
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      board[5 * 7 + 0] = TurnBasedGameCellState.player1;
      board[5 * 7 + 1] = TurnBasedGameCellState.player1;
      board[5 * 7 + 2] = TurnBasedGameCellState.player1;
      board[5 * 7 + 3] = TurnBasedGameCellState.empty; // Winning move

      final startTime = DateTime.now();
      final result = engine.iterativeDeepening(
        board,
        TurnBasedGameCellState.player1,
        500,
      );
      final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;

      expect(
        elapsedTime,
        lessThanOrEqualTo(500),
      ); // Ensure time cap is respected
      expect(result.move, equals(3)); // Ensure the winning move is selected
    });

    test('Iterative deepening finds best move within time cap', () {
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      board[5 * 7 + 0] = TurnBasedGameCellState.player2;
      board[5 * 7 + 1] = TurnBasedGameCellState.player2;
      board[5 * 7 + 2] = TurnBasedGameCellState.player2;
      board[5 * 7 + 3] = TurnBasedGameCellState.empty; // Blocking move

      final result = engine.iterativeDeepening(
        board,
        TurnBasedGameCellState.player1,
        500,
      );

      expect(result.move, equals(3)); // Ensure the blocking move is selected
    });
  });
}
