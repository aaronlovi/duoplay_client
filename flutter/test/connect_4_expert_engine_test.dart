import 'package:duoplay/engines/connect_4/connect_4_expert_engine.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Connect4ExpertEngine - Static Board Evaluator', () {
    final engine = Connect4ExpertEngine();

    test('Center weighting metric prioritizes center columns', () {
      final board = List.generate(
        6,
        (_) => List.generate(7, (_) => Connect4SquareState.empty),
      );
      board[5][3] = Connect4SquareState.red; // Place a chip in the center

      final score = engine.evaluateCenterWeighting(board, Connect4SquareState.red);

      expect(score, greaterThan(0)); // Ensure center chip contributes to score
    });

    test('Potential connections metric identifies open sequences', () {
      final board = List.generate(
        6,
        (_) => List.generate(7, (_) => Connect4SquareState.empty),
      );
      board[5][0] = Connect4SquareState.red;
      board[5][1] = Connect4SquareState.red;
      board[5][2] = Connect4SquareState.empty;
      board[5][3] = Connect4SquareState.empty;

      final score = engine.evaluatePotentialConnections(board, Connect4SquareState.red);

      expect(score, greaterThan(0)); // Ensure open sequences contribute to score
    });
  });

  group('Connect4ExpertEngine - Minimax with Alpha-Beta Pruning', () {
    final engine = Connect4ExpertEngine();

    test('Alpha-beta pruning avoids unnecessary branches', () {
      final board = List.generate(
        6,
        (_) => List.generate(7, (_) => Connect4SquareState.empty),
      );
      board[5][0] = Connect4SquareState.red;
      board[5][1] = Connect4SquareState.red;
      board[5][2] = Connect4SquareState.red;
      board[5][3] = Connect4SquareState.empty; // Winning move

      final result = engine.minimaxWithAlphaBeta(
        board,
        4, // Depth limit
        true,
        Connect4SquareState.red,
        -10000,
        10000,
      );

      expect(result.move, equals(3)); // Ensure the winning move is selected
      expect(result.score, greaterThan(0)); // Positive score for a win
    });

    test('Alpha-beta pruning blocks opponent win', () {
      final board = List.generate(
        6,
        (_) => List.generate(7, (_) => Connect4SquareState.empty),
      );
      board[5][0] = Connect4SquareState.yellow;
      board[5][1] = Connect4SquareState.yellow;
      board[5][2] = Connect4SquareState.yellow;
      board[5][3] = Connect4SquareState.empty; // Blocking move

      final result = engine.minimaxWithAlphaBeta(
        board,
        4, // Depth limit
        true,
        Connect4SquareState.red,
        -10000,
        10000,
      );

      expect(result.move, equals(3)); // Ensure the blocking move is selected
      expect(result.score, lessThan(1000)); // Score should not indicate a win
    });
  });
}
