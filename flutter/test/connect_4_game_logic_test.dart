import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Connect4GameLogic', () {
    late List<List<Connect4SquareState>> board;

    setUp(() {
      board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, Connect4SquareState.empty),
      );
    });

    test('isLegalMove returns true for an empty column', () {
      expect(Connect4GameLogic.isLegalMove(board, 0), isTrue);
    });

    test('isLegalMove returns false for a full column', () {
      for (int row = 0; row < Connect4GameLogic.rows; row++) {
        board[row][0] = Connect4SquareState.red;
      }
      expect(Connect4GameLogic.isLegalMove(board, 0), isFalse);
    });

    test('applyMove places a chip in the lowest available row', () {
      Connect4GameLogic.applyMove(board, 0, Connect4SquareState.red);
      expect(board[Connect4GameLogic.rows - 1][0], Connect4SquareState.red);
    });

    test('getWinner detects a horizontal win', () {
      for (int col = 0; col < 4; col++) {
        board[0][col] = Connect4SquareState.red;
      }
      expect(Connect4GameLogic.getWinner(board), Connect4SquareState.red);
    });

    test('getWinner detects a vertical win', () {
      for (int row = 0; row < 4; row++) {
        board[row][0] = Connect4SquareState.yellow;
      }
      expect(Connect4GameLogic.getWinner(board), Connect4SquareState.yellow);
    });

    test('getWinner detects a diagonal win (down-right)', () {
      for (int i = 0; i < 4; i++) {
        board[i][i] = Connect4SquareState.red;
      }
      expect(Connect4GameLogic.getWinner(board), Connect4SquareState.red);
    });

    test('getWinner detects a diagonal win (down-left)', () {
      for (int i = 0; i < 4; i++) {
        board[i][3 - i] = Connect4SquareState.yellow;
      }
      expect(Connect4GameLogic.getWinner(board), Connect4SquareState.yellow);
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

      board = Connect4GameLogic.parseBoard(boardString);

      expect(Connect4GameLogic.isDraw(board), isTrue);
    });

    test('isDraw returns false for a non-full board', () {
      board[0][0] = Connect4SquareState.red;
      expect(Connect4GameLogic.isDraw(board), isFalse);
    });
  });

  group('Connect4GameLogic - Illegal Moves', () {
    test('Selecting a full column should be illegal', () {
      // Arrange: Create a board with a full column
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, Connect4SquareState.empty),
      );
      final columnToFill = 3;
      for (int row = 0; row < Connect4GameLogic.rows; row++) {
        board[row][columnToFill] = Connect4SquareState.red;
      }

      // Act: Check if the move is legal
      final isLegal = Connect4GameLogic.isLegalMove(board, columnToFill);

      // Assert: The move should be illegal
      expect(isLegal, isFalse);
    });
  });

  group('Connect4GameLogic - Win Conditions', () {
    test('Detect horizontal win', () {
      // Arrange: Create a board with a horizontal win
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, Connect4SquareState.empty),
      );
      for (int col = 0; col < 4; col++) {
        board[0][col] = Connect4SquareState.red;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be red
      expect(winner, Connect4SquareState.red);
    });

    test('Detect vertical win', () {
      // Arrange: Create a board with a vertical win
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, Connect4SquareState.empty),
      );
      for (int row = 0; row < 4; row++) {
        board[row][0] = Connect4SquareState.yellow;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be yellow
      expect(winner, Connect4SquareState.yellow);
    });

    test('Detect diagonal win (down-right)', () {
      // Arrange: Create a board with a diagonal win (down-right)
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, Connect4SquareState.empty),
      );
      for (int i = 0; i < 4; i++) {
        board[i][i] = Connect4SquareState.red;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be red
      expect(winner, Connect4SquareState.red);
    });

    test('Detect diagonal win (down-left)', () {
      // Arrange: Create a board with a diagonal win (down-left)
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, Connect4SquareState.empty),
      );
      for (int i = 0; i < 4; i++) {
        board[i][3 - i] = Connect4SquareState.yellow;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be yellow
      expect(winner, Connect4SquareState.yellow);
    });
  });

  group('Connect4GameLogic - Draw Detection', () {
    test('Detect draw on a completely filled board with no winner', () {
      // Arrange: Create a full board with no winner
      final board = Connect4GameLogic.parseBoard('''
       Y R Y R Y Y R 
       R R Y R R R Y 
       Y Y R Y Y R Y 
       Y R R Y R R Y 
       Y Y R R Y Y R 
       R R Y Y R Y R 
      ''');

      // Act: Check if the board is a draw
      final isDraw = Connect4GameLogic.isDraw(board);

      // Assert: The board should be a draw
      expect(isDraw, isTrue);
    });

    test('Detect non-draw on a partially filled board', () {
      // Arrange: Create a partially filled board
      final board = Connect4GameLogic.parseBoard('''
       Y R Y R Y Y R 
       R R Y R R R Y 
       Y Y R Y Y R Y 
       Y R R Y R R Y 
       Y Y R R Y Y R 
       R R Y Y R Y .
      ''');

      // Act: Check if the board is a draw
      final isDraw = Connect4GameLogic.isDraw(board);

      // Assert: The board should not be a draw
      expect(isDraw, isFalse);
    });
  });
}