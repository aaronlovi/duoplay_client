import 'dart:developer';
import 'package:duoplay/engines/connect_4/connect_4_engine_factory.dart';
import 'package:duoplay/models/connect_4/connect_4_enums.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_inputs.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_outputs.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/result.dart';

class Connect4FSM {
  Connect4GameState gameState;
  final List<Connect4OutputBase> _outputs = [];

  Connect4FSM(this.gameState);

  void update(Connect4InputBase input, List<Connect4OutputBase> outputs) {
    final prevState = gameState.toString();
    final inputType = input.runtimeType.toString();
    log('[FSM] Transition: prevState=$prevState, inputType=$inputType, input=$input');

    _outputs.clear();
    outputs.clear();
    gameState.nowUtc = input.nowUtc;

    if (input is Connect4GameConfigInput) {
      _processGameConfiguration(input);
    } else if (input is Connect4SettingsChangeInput) {
      _processSettingsChange(input);
    } else if (input is Connect4PlayerMoveInput) {
      _processPlayerMove(input);
    } else if (input is Connect4EngineMoveInput) {
      _processEngineMove(input);
    } else if (input is Connect4UpdateTime) {
      // No action needed
    }

    outputs.addAll(_outputs);
  }

  void _processGameConfiguration(Connect4GameConfigInput input) {
    log('Processing game configuration: ${input.configuration}');
    gameState.processNewGameConfiguration(input.configuration, input.nowUtc);
    _outputs.add(Connect4StartGameOutput(input.configuration));
  }

  void _processSettingsChange(Connect4SettingsChangeInput input) {
    gameState.nextGameEngineDifficulty = input.newDifficulty;
    gameState.configuration.betweenGamesWaitTime = Duration(seconds: input.betweenGameDelaySeconds);
    gameState.configuration.engineMoveWaitTime = Duration(seconds: input.betweenMoveDelaySeconds);
  }

  void _processPlayerMove(Connect4PlayerMoveInput input) {
    log('Processing player move: column=${input.column}, player=${input.player}');
    if (input.player == gameState.configuration.enginePlayer || input.player == Connect4SquareState.empty) {
      log('Invalid move: Player is engine or empty');
      _outputs.add(Connect4ErrorOutput(results: Result.failure(ResultErrorCode.invalidMove)));
      return;
    }

    final result = gameState.makeMove(input.column, input.player);
    if (result.isFailure) {
      log('Move failed: ${result.errorCode}');
      _outputs.add(Connect4ErrorOutput(results: result));
      return;
    }

    log('Move successful: column=${input.column}, player=${input.player}');
    _outputs.add(Connect4NewBoardOutput(board: gameState.board));

    if (gameState.isGameOver) {
      log('Game over: winner=${gameState.winner}, isDraw=${gameState.isDraw}');
      _outputs.add(Connect4GameOverOutput(winner: gameState.winner, isDraw: gameState.isDraw));
    }
  }

  void _processEngineMove(Connect4EngineMoveInput input) {
    log('Processing engine move: column=${input.column}, enginePlayer=${input.enginePlayer}');
    if (input.enginePlayer != gameState.configuration.enginePlayer || input.enginePlayer == Connect4SquareState.empty) {
      log('Invalid engine move: Player mismatch or empty');
      _outputs.add(Connect4ErrorOutput(results: Result.failure(ResultErrorCode.invalidMove)));
      return;
    }

    final result = gameState.makeMove(input.column, input.enginePlayer);
    if (result.isFailure) {
      log('Engine move failed: ${result.errorCode}');
      _outputs.add(Connect4ErrorOutput(results: result));
      return;
    }

    log('Engine move successful: column=${input.column}, enginePlayer=${input.enginePlayer}');
    _outputs.add(Connect4NewBoardOutput(board: gameState.board));

    if (gameState.isGameOver) {
      log('Game over: winner=${gameState.winner}, isDraw=${gameState.isDraw}');
      _outputs.add(Connect4GameOverOutput(winner: gameState.winner, isDraw: gameState.isDraw));
    }
  }
}
