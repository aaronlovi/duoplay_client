import 'dart:math';

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
        if (currentState.getWinner(simulatedBoard) == currentState.currentPlayer) {
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
      return GenericResult.success(legalMoves[randomIndex]);
    }

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
        if (currentState.getWinner(simulatedBoard) == currentState.currentPlayer) {
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
      return GenericResult.success(legalMoves[randomIndex]);
    }

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

    final bestMove = _minimax(currentState, currentState.currentPlayer, true).move;
    if (bestMove != null) {
      return GenericResult.success(bestMove);
    }

    return GenericResult.failure(ResultErrorCode.invalidState);
  }

  _MinimaxResult _minimax(TicTacToeGameState state, TTTCellState player, bool isMaximizing) {
    if (state.isGameOver) {
      if (state.winner == state.currentPlayer) {
        return _MinimaxResult(score: 10);
      } else if (state.winner == state.currentPlayer.getOpponent()) {
        return _MinimaxResult(score: -10);
      } else {
        return _MinimaxResult(score: 0);
      }
    }

    final moves = <_MinimaxResult>[];
    for (int i = 0; i < state.board.length; ++i) {
      if (state.board[i] == TTTCellState.empty) {
        final newState = _simulateMove(state, i, player);
        final result = _minimax(newState, player.getOpponent(), !isMaximizing);
        moves.add(_MinimaxResult(move: i, score: result.score));
      }
    }

    if (isMaximizing) {
      return moves.reduce((a, b) => a.score > b.score ? a : b);
    } else {
      return moves.reduce((a, b) => a.score < b.score ? a : b);
    }
  }

  TicTacToeGameState _simulateMove(TicTacToeGameState state, int index, TTTCellState player) {
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
