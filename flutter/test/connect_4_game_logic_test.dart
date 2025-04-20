import 'package:duoplay/models/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_board.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Connect4GameLogic', () {
    final gameLogic = Connect4GameLogic();
    late TurnBasedGameBoard board;

    setUp(() => board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns));

    test('isLegalMove returns true for an empty column', () {
      expect(gameLogic.isLegalMove(board, 0), isTrue);
    });

    test('isLegalMove returns false for a full column', () {
      for (int row = 0; row < gameLogic.rows; row++) {
        board[row * gameLogic.columns + 0] = TurnBasedGameCellState.player1;
      }
      expect(gameLogic.isLegalMove(board, 0), isFalse);
    });

    test('applyMove places a chip in the lowest available row', () {
      gameLogic.applyMove(board, 0, TurnBasedGameCellState.player1);
      expect(
        board[(gameLogic.rows - 1) * gameLogic.columns + 0],
        TurnBasedGameCellState.player1,
      );
    });

    test('getWinner detects a horizontal win', () {
      for (int col = 0; col < 4; col++) {
        board[0 * gameLogic.columns + col] = TurnBasedGameCellState.player1;
      }
      expect(gameLogic.getWinner(board), TurnBasedGameCellState.player1);
    });

    test('getWinner detects a vertical win', () {
      for (int row = 0; row < 4; row++) {
        board[row * gameLogic.columns + 0] = TurnBasedGameCellState.player2;
      }
      expect(gameLogic.getWinner(board), TurnBasedGameCellState.player2);
    });

    test('getWinner detects a diagonal win (down-right)', () {
      for (int i = 0; i < 4; i++) {
        board[i * gameLogic.columns + i] = TurnBasedGameCellState.player1;
      }
      expect(gameLogic.getWinner(board), TurnBasedGameCellState.player1);
    });

    test('getWinner detects a diagonal win (down-left)', () {
      for (int i = 0; i < 4; i++) {
        board[i * gameLogic.columns + (3 - i)] = TurnBasedGameCellState.player2;
      }
      expect(gameLogic.getWinner(board), TurnBasedGameCellState.player2);
    });

    test('isDraw returns true for a full board with no winner', () {
      final boardString = '''
       Y R  Y  R  Y  Y  R 
       R R  Y  R  R  R  Y 
       Y Y  R  Y  Y  R  Y 
       Y  R  R  Y  R  R  Y 
       Y  Y  R  R  Y  Y  R 
       R  R  Y  Y  R  Y  R 
      ''';

      board = gameLogic.parseBoard(boardString);

      expect(gameLogic.isDraw(board), isTrue);
    });

    test('isDraw returns false for a non-full board', () {
      board[0 * gameLogic.columns + 0] = TurnBasedGameCellState.player1;
      expect(gameLogic.isDraw(board), isFalse);
    });
  });

  group('Connect4GameLogic - Illegal Moves', () {
    final gameLogic = Connect4GameLogic();

    test('Selecting a full column should be illegal', () {
      // Arrange: Create a board with a full column
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      final columnToFill = 3;
      for (int row = 0; row < gameLogic.rows; row++) {
        board[row * gameLogic.columns + columnToFill] =
            TurnBasedGameCellState.player1;
      }

      // Act: Check if the move is legal
      final isLegal = gameLogic.isLegalMove(board, columnToFill);

      // Assert: The move should be illegal
      expect(isLegal, isFalse);
    });
  });

  group('Connect4GameLogic - Win Conditions', () {
    final gameLogic = Connect4GameLogic();

    test('Detect horizontal win', () {
      // Arrange: Create a board with a horizontal win
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      for (int col = 0; col < 4; col++) {
        board[0 * gameLogic.columns + col] = TurnBasedGameCellState.player1;
      }

      // Act: Check for a winner
      final winner = gameLogic.getWinner(board);

      // Assert: The winner should be red
      expect(winner, TurnBasedGameCellState.player1);
    });

    test('Detect vertical win', () {
      // Arrange: Create a board with a vertical win
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      for (int row = 0; row < 4; row++) {
        board[row * gameLogic.columns + 0] = TurnBasedGameCellState.player2;
      }

      // Act: Check for a winner
      final winner = gameLogic.getWinner(board);

      // Assert: The winner should be yellow
      expect(winner, TurnBasedGameCellState.player2);
    });

    test('Detect diagonal win (down-right)', () {
      // Arrange: Create a board with a diagonal win (down-right)
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      for (int i = 0; i < 4; i++) {
        board[i * gameLogic.columns + i] = TurnBasedGameCellState.player1;
      }

      // Act: Check for a winner
      final winner = gameLogic.getWinner(board);

      // Assert: The winner should be red
      expect(winner, TurnBasedGameCellState.player1);
    });

    test('Detect diagonal win (down-left)', () {
      // Arrange: Create a board with a diagonal win (down-left)
      final board = TurnBasedGameBoard(gameLogic.rows, gameLogic.columns);
      for (int i = 0; i < 4; i++) {
        board[i * gameLogic.columns + (3 - i)] = TurnBasedGameCellState.player2;
      }

      // Act: Check for a winner
      final winner = gameLogic.getWinner(board);

      // Assert: The winner should be yellow
      expect(winner, TurnBasedGameCellState.player2);
    });
  });

  group('Connect4GameLogic - Draw Detection', () {
    final gameLogic = Connect4GameLogic();

    test('Detect draw on a completely filled board with no winner', () {
      // Arrange: Create a full board with no winner
      final board = gameLogic.parseBoard('''
       Y R Y R Y Y R 
       R R Y R R R Y 
       Y Y R Y Y R Y 
       Y R R Y R R Y 
       Y Y R R Y Y R 
       R R Y Y R Y R 
      ''');

      // Act: Check if the board is a draw
      final isDraw = gameLogic.isDraw(board);

      // Assert: The board should be a draw
      expect(isDraw, isTrue);
    });

    test('Detect non-draw on a partially filled board', () {
      // Arrange: Create a partially filled board
      final board = gameLogic.parseBoard('''
       Y R Y R Y Y R 
       R R Y R R R Y 
       Y Y R Y Y R Y 
       Y R R Y R R Y 
       Y Y R R Y Y R 
       R R Y Y R Y .
      ''');

      // Act: Check if the board is a draw
      final isDraw = gameLogic.isDraw(board);

      // Assert: The board should not be a draw
      expect(isDraw, isFalse);
    });
  });
}
