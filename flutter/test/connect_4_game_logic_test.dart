import 'package:duoplay/engines/connect_4/connect_4_game_logic.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Connect4GameLogic', () {
    late List<List<TurnBasedGameCellState>> board;

    setUp(() {
      board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
      );
    });

    test('isLegalMove returns true for an empty column', () {
      expect(Connect4GameLogic.isLegalMove(board, 0), isTrue);
    });

    test('isLegalMove returns false for a full column', () {
      for (int row = 0; row < Connect4GameLogic.rows; row++) {
        board[row][0] = TurnBasedGameCellState.player1;
      }
      expect(Connect4GameLogic.isLegalMove(board, 0), isFalse);
    });

    test('applyMove places a chip in the lowest available row', () {
      Connect4GameLogic.applyMove(board, 0, TurnBasedGameCellState.player1);
      expect(board[Connect4GameLogic.rows - 1][0], TurnBasedGameCellState.player1);
    });

    test('getWinner detects a horizontal win', () {
      for (int col = 0; col < 4; col++) {
        board[0][col] = TurnBasedGameCellState.player1;
      }
      expect(Connect4GameLogic.getWinner(board), TurnBasedGameCellState.player1);
    });

    test('getWinner detects a vertical win', () {
      for (int row = 0; row < 4; row++) {
        board[row][0] = TurnBasedGameCellState.player2;
      }
      expect(Connect4GameLogic.getWinner(board), TurnBasedGameCellState.player2);
    });

    test('getWinner detects a diagonal win (down-right)', () {
      for (int i = 0; i < 4; i++) {
        board[i][i] = TurnBasedGameCellState.player1;
      }
      expect(Connect4GameLogic.getWinner(board), TurnBasedGameCellState.player1);
    });

    test('getWinner detects a diagonal win (down-left)', () {
      for (int i = 0; i < 4; i++) {
        board[i][3 - i] = TurnBasedGameCellState.player2;
      }
      expect(Connect4GameLogic.getWinner(board), TurnBasedGameCellState.player2);
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
      board[0][0] = TurnBasedGameCellState.player1;
      expect(Connect4GameLogic.isDraw(board), isFalse);
    });
  });

  group('Connect4GameLogic - Illegal Moves', () {
    test('Selecting a full column should be illegal', () {
      // Arrange: Create a board with a full column
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
      );
      final columnToFill = 3;
      for (int row = 0; row < Connect4GameLogic.rows; row++) {
        board[row][columnToFill] = TurnBasedGameCellState.player1;
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
        (_) => List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
      );
      for (int col = 0; col < 4; col++) {
        board[0][col] = TurnBasedGameCellState.player1;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be red
      expect(winner, TurnBasedGameCellState.player1);
    });

    test('Detect vertical win', () {
      // Arrange: Create a board with a vertical win
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
      );
      for (int row = 0; row < 4; row++) {
        board[row][0] = TurnBasedGameCellState.player2;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be yellow
      expect(winner, TurnBasedGameCellState.player2);
    });

    test('Detect diagonal win (down-right)', () {
      // Arrange: Create a board with a diagonal win (down-right)
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
      );
      for (int i = 0; i < 4; i++) {
        board[i][i] = TurnBasedGameCellState.player1;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be red
      expect(winner, TurnBasedGameCellState.player1);
    });

    test('Detect diagonal win (down-left)', () {
      // Arrange: Create a board with a diagonal win (down-left)
      final board = List.generate(
        Connect4GameLogic.rows,
        (_) => List.filled(Connect4GameLogic.columns, TurnBasedGameCellState.empty),
      );
      for (int i = 0; i < 4; i++) {
        board[i][3 - i] = TurnBasedGameCellState.player2;
      }

      // Act: Check for a winner
      final winner = Connect4GameLogic.getWinner(board);

      // Assert: The winner should be yellow
      expect(winner, TurnBasedGameCellState.player2);
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