import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicTacToeGameState', () {
    test('validateMove detects invalid moves', () {
      final config = TurnBasedGameConfiguration.defaults();
      final gameState = TicTacToeGameState.initial(config);

      // Test out-of-bounds move
      expect(gameState.validateMove(-1).isFailure, true);
      expect(gameState.validateMove(9).isFailure, true);

      // Test move on occupied cell
      gameState.board[0] = TurnBasedGameCellState.player1;
      expect(gameState.validateMove(0).isFailure, true);

      // Test valid move
      expect(gameState.validateMove(1).isSuccess, true);
    });

    test('Simultaneous win and draw conditions', () {
      final config = TurnBasedGameConfiguration.defaults();
      final gameState = TicTacToeGameState.initial(config);

      // Set up a board state where the last move results in both a win and a full board
      // Create a potential diagonal win (0, 4, 8) when X plays at position 8
      gameState.board[0] = TurnBasedGameCellState.player1;
      gameState.board[1] = TurnBasedGameCellState.player2;
      gameState.board[2] = TurnBasedGameCellState.player1;
      gameState.board[3] = TurnBasedGameCellState.player1;
      gameState.board[4] = TurnBasedGameCellState.player1;
      gameState.board[5] = TurnBasedGameCellState.player2;
      gameState.board[6] = TurnBasedGameCellState.player2;
      gameState.board[7] = TurnBasedGameCellState.player2;
      gameState.board[8] = TurnBasedGameCellState.empty;

      // Update the game state counts to match the board
      gameState.numberOfX = 4;
      gameState.numberOfO = 4;
      
      // Ensure the current player is set to X since we want X to make the move
      gameState.currentPlayer = TurnBasedGameCellState.player1;

      // Make the final move
      final result = gameState.makeMove(8, TurnBasedGameCellState.player1);
      
      // Verify the result and game state
      expect(result.isSuccess, true);
      
      // Make sure we have a horizontal win in the top row (0,1,8)
      expect(gameState.board[0], TurnBasedGameCellState.player1);
      expect(gameState.board[4], TurnBasedGameCellState.player1);
      expect(gameState.board[8], TurnBasedGameCellState.player1);
      
      // Check win-related properties
      expect(gameState.winner, TurnBasedGameCellState.player1, reason: "X should be marked as the winner");
      expect(gameState.hasWinner, true, reason: "hasWinner should be true");
      expect(gameState.isDraw, false, reason: "isDraw should be false since we have a winner");
      expect(gameState.isGameOver, true, reason: "Game should be marked as over");
      expect(gameState.numberOfX, 5, reason: "Should be 5 Xs on the board");
      expect(gameState.numberOfO, 4, reason: "Should be 4 Os on the board");
    });
  });
}
