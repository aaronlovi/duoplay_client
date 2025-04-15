import 'dart:math';
import 'dart:developer' as developer;

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_constants.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';

class TTTBasicEngine implements TTTEngineContract {
  final random = Random();

  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    final blockingMoves = <int>[];
    final otherMoves = <int>[];
    final playerToMove = currentState.currentPlayer;
    final otherPlayer = playerToMove.getOpponent();
    final currentBoard = currentState.board;

    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] != TTTCellState.empty) continue;

      for (var combination in TTTConstants.winningCombinations) {
        if (!combination.contains(i)) continue;

        int numSquaresOccupiedByCurrentPlayer = 0;
        int numSquaresOccupiedByOpponent = 0;
        for (var index in combination) {
          if (currentBoard[index] == playerToMove) {
            ++numSquaresOccupiedByCurrentPlayer;
          } else if (currentBoard[index] == otherPlayer) {
            ++numSquaresOccupiedByOpponent;
          }
        }
        if (numSquaresOccupiedByCurrentPlayer == 2) {
          // Two squares occupied by player and one empty square,
          // So this move is a win
          return GenericResult.success(i);
        } else if (numSquaresOccupiedByOpponent == 2) {
          // Two squares occupied by opponent and one empty square,
          // So this is a blocking move
          blockingMoves.add(i);
        } else {
          otherMoves.add(i);
        }
      }
    }

    if (blockingMoves.isNotEmpty) {
      final randomIndex = random.nextInt(blockingMoves.length);
      return GenericResult.success(blockingMoves[randomIndex]);
    }

    if (otherMoves.isNotEmpty) {
      final randomIndex = random.nextInt(otherMoves.length);
      return GenericResult.success(otherMoves[randomIndex]);
    }

    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}

class BeginnerEngine extends TTTBasicEngine {
  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    // Try to make an immediately winning move
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        final simulatedBoard = List<TTTCellState>.from(currentState.board);
        simulatedBoard[i] = currentState.currentPlayer;
        if (currentState.getWinner(simulatedBoard) ==
            currentState.currentPlayer) {
          developer.log('[AI][Beginner] Winning move found at $i');
          return GenericResult.success(i);
        }
      }
    }

    // Otherwise, make a random legal move
    final legalMoves = <int>[];
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        legalMoves.add(i);
      }
    }

    if (legalMoves.isNotEmpty) {
      final randomIndex = random.nextInt(legalMoves.length);
      developer.log(
        '[AI][Beginner] No winning move, picking random move at ${legalMoves[randomIndex]}',
      );
      return GenericResult.success(legalMoves[randomIndex]);
    }

    developer.log('[AI][Beginner] No legal moves available');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}

class IntermediateEngine extends TTTBasicEngine {
  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    // Try to make an immediately winning move
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        final simulatedBoard = List<TTTCellState>.from(currentState.board);
        simulatedBoard[i] = currentState.currentPlayer;
        if (currentState.getWinner(simulatedBoard) ==
            currentState.currentPlayer) {
          developer.log('[AI][Intermediate] Winning move found at $i');
          return GenericResult.success(i);
        }
      }
    }

    // Try to block opponent's immediately winning move
    final opponent = currentState.currentPlayer.getOpponent();
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        final simulatedBoard = List<TTTCellState>.from(currentState.board);
        simulatedBoard[i] = opponent;
        if (currentState.getWinner(simulatedBoard) == opponent) {
          developer.log('[AI][Intermediate] Blocking opponent win at $i');
          return GenericResult.success(i);
        }
      }
    }

    // Otherwise, make a random legal move
    final legalMoves = <int>[];
    for (int i = 0; i < currentState.board.length; ++i) {
      if (currentState.board[i] == TTTCellState.empty) {
        legalMoves.add(i);
      }
    }

    if (legalMoves.isNotEmpty) {
      final randomIndex = random.nextInt(legalMoves.length);
      developer.log(
        '[AI][Intermediate] No win/block, picking random move at ${legalMoves[randomIndex]}',
      );
      return GenericResult.success(legalMoves[randomIndex]);
    }

    developer.log('[AI][Intermediate] No legal moves available');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }
}

class ExpertEngine extends TTTBasicEngine {
  @override
  GenericResult<int> getNextMove(TicTacToeGameState currentState) {
    Result res = currentState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      return GenericResult.failure(ResultErrorCode.invalidState);
    }

    // Remove forced center pick: always use minimax
    final bestMove =
        _minimax(currentState, currentState.currentPlayer, true).move;
    if (bestMove != null) {
      developer.log('[AI][Expert] Minimax selected move $bestMove');
      return GenericResult.success(bestMove);
    }

    developer.log('[AI][Expert] No valid move found by minimax');
    return GenericResult.failure(ResultErrorCode.invalidState);
  }

  _MinimaxResult _minimax(
    TicTacToeGameState state,
    TTTCellState player,
    bool isMaximizing,
  ) {
    // Center bonus value
    const int centerBonus = 1;
    if (state.isGameOver) {
      int score;
      if (state.winner == state.currentPlayer) {
        score = 10;
      } else if (state.winner == state.currentPlayer.getOpponent()) {
        score = -10;
      } else {
        score = 0;
      }
      // Add bonus if player occupies center
      if (state.board[4] == state.currentPlayer) {
        score += centerBonus;
      }
      return _MinimaxResult(score: score);
    }

    final moves = <_MinimaxResult>[];
    for (int i = 0; i < state.board.length; ++i) {
      if (state.board[i] == TTTCellState.empty) {
        final newState = _simulateMove(state, i, player);
        final result = _minimax(newState, player.getOpponent(), !isMaximizing);
        int moveScore = result.score;
        // Add bonus if this move is the center
        if (i == 4 && player == state.currentPlayer) {
          moveScore += centerBonus;
        }
        moves.add(_MinimaxResult(move: i, score: moveScore));
      }
    }

    if (isMaximizing) {
      return moves.reduce((a, b) => a.score > b.score ? a : b);
    } else {
      return moves.reduce((a, b) => a.score < b.score ? a : b);
    }
  }

  TicTacToeGameState _simulateMove(
    TicTacToeGameState state,
    int index,
    TTTCellState player,
  ) {
    final newBoard = List<TTTCellState>.from(state.board);
    newBoard[index] = player;
    return TicTacToeGameState(
      newBoard,
      player.getOpponent(),
      state.getWinner(newBoard),
      player == TTTCellState.x ? state.numberOfX + 1 : state.numberOfX,
      player == TTTCellState.o ? state.numberOfO + 1 : state.numberOfO,
      state.nowUtc,
      state.configuration,
    );
  }
}

class _MinimaxResult {
  final int? move;
  final int score;

  _MinimaxResult({this.move, required this.score});
}

class EngineFactory {
  static TTTBasicEngine createEngine(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return BeginnerEngine();
      case 'intermediate':
        return IntermediateEngine();
      case 'expert':
        return ExpertEngine();
      default:
        throw ArgumentError('Invalid difficulty level: $difficulty');
    }
  }
}
