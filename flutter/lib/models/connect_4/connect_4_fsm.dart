import 'dart:developer';

import 'package:duoplay/engines/connect_4/connect_4_engine_contract.dart';
import 'package:duoplay/engines/connect_4/connect_4_engine_factory.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_inputs.dart';
import 'package:duoplay/models/connect_4/connect_4_fsm_outputs.dart';
import 'package:duoplay/models/connect_4/connect_4_game_state.dart';
import 'package:duoplay/models/connect_4/connect_4_output_container.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class _Connect4FsmUpdateContext {
  bool addStartGameOutput;
  bool addDoEngineMoveOutput;

  _Connect4FsmUpdateContext()
    : addStartGameOutput = false,
      addDoEngineMoveOutput = false;

  void clear() {
    addStartGameOutput = false;
    addDoEngineMoveOutput = false;
  }
}

class Connect4FSM {
  Connect4GameState gameState;
  final Connect4OutputContainer _outputs;
  final _Connect4FsmUpdateContext _context;
  late Connect4EngineContract _engine;

  Connect4FSM(TurnBasedGameConfiguration configuration)
    : gameState = Connect4GameState.initial(configuration),
      _outputs = Connect4OutputContainer(outputs: <TurnBasedGameFsmOutputBase>[]),
      _context = _Connect4FsmUpdateContext() {
    _engine = Connect4EngineFactory.createEngine(configuration.difficulty);
  }

  List<List<TurnBasedGameCellState>> get board => gameState.board;
  bool get isPlayerRedEngine =>
      gameState.configuration.enginePlayer == TurnBasedGameCellState.player1;
  bool get isPlayerYellowEngine =>
      gameState.configuration.enginePlayer == TurnBasedGameCellState.player2;
  bool get isHumanPlayerToMove => gameState.isHumanPlayerToMove;
  TurnBasedGameCellState get humanPlayer => gameState.humanPlayer;
  TurnBasedGameCellState get enginePlayer => gameState.enginePlayer;
  String get nextGameDifficulty => gameState.nextGameEngineDifficulty;

  void update(Connect4InputBase inputs, Connect4OutputContainer outputs) {
    final prevState = gameState.toString();
    final inputType = inputs.runtimeType.toString();
    log(
      '[FSM] Transition: prevState=$prevState, inputType=$inputType, input=$inputs',
    );

    _outputs.clear();
    _context.clear();
    outputs.clear();
    gameState.nowUtc = inputs.nowUtc;

    if (inputs is Connect4GameConfigInput) {
      _processGameConfiguration(inputs);
    } else if (inputs is Connect4SettingsChangeInput) {
      _processSettingsChange(inputs);
    } else if (inputs is Connect4PlayerMoveInput) {
      _processPlayerMove(inputs);
    } else if (inputs is Connect4EngineMoveInput) {
      _processEngineMove(inputs);
    } else if (inputs is Connect4UpdateTime) {
      // No action needed
    }

    _processUpdateTime();
    _processUpdateContext();

    outputs.outputs.addAll(_outputs.outputs);
    outputs.nextTimeout = _getNextTimeout();
    log('[FSM] Transition: newState=${gameState.toString()}');
  }

  void _processSettingsChange(Connect4SettingsChangeInput inputs) {
    gameState.nextGameEngineDifficulty = inputs.newDifficulty;
    if (gameState.isBetweenGames) _updateEngineDifficulty();
    gameState.configuration.betweenGamesWaitTime = Duration(
      seconds: inputs.betweenGameDelaySeconds,
    );
    gameState.configuration.engineMoveWaitTime = Duration(
      seconds: inputs.betweenMoveDelaySeconds,
    );
  }

  // Reset the game board with the new configuration
  void _processGameConfiguration(Connect4GameConfigInput input) {
    log('Processing game configuration: ${input.configuration}');
    gameState.processNewGameConfiguration(input.configuration, input.nowUtc);
    _updateEngineDifficulty();
    _outputs.outputs.add(TurnBasedGameStartGameFsmOutput(input.configuration));
  }

  void _processPlayerMove(Connect4PlayerMoveInput inputs) {
    log(
      'Processing player move: column=${inputs.column}, player=${inputs.player}',
    );
    if (inputs.player == gameState.configuration.enginePlayer ||
        inputs.player == TurnBasedGameCellState.empty) {
      log('Invalid move: Player is engine or empty');
      _appendErrorOutput(ResultErrorCode.invalidMove);
      return;
    }

    Result res = gameState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      log('Move failed validation: ${res.errorCode}');
      _appendErrorResult(res);
      return;
    }

    res = gameState.makeMove(inputs.column, inputs.player);
    if (res.isFailure) {
      log('Move failed: ${res.errorCode}');
      _appendErrorResult(res);
      return;
    }

    log('Move successful: column=${inputs.column}, player=${inputs.player}');
    _outputs.outputs.add(Connect4NewBoardOutput(gameState: gameState));
    if (gameState.isGameOver) {
      log('Game over: winner=${gameState.winner}, isDraw=${gameState.isDraw}');
      _outputs.outputs.add(
        TurnBasedGameGameOverFsmOutput(
          winner: gameState.winner,
          isDraw: gameState.isDraw,
        ),
      );
    }
  }

  void _processEngineMove(Connect4EngineMoveInput inputs) {
    log(
      'Processing engine move: column=${inputs.column}, enginePlayer=${inputs.enginePlayer}',
    );
    if (inputs.enginePlayer != gameState.configuration.enginePlayer ||
        inputs.enginePlayer == TurnBasedGameCellState.empty) {
      log('Invalid engine move: Player mismatch or empty');
      _appendErrorOutput(ResultErrorCode.invalidMove);
      return;
    }

    Result res = gameState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      log('Engine move failed validation: ${res.errorCode}');
      _appendErrorResult(res);
      return;
    }

    // Use the selected engine to get the move
    final aiMove = _engine.getNextMove(gameState);
    log(
      '[FSM] AI (difficulty: ${gameState.configuration.difficulty}) selected move: ${aiMove.value}, reason: ${aiMove.isSuccess ? 'success' : 'failure'}',
    );
    if (aiMove.isFailure) {
      _appendErrorResult(Result.failure(ResultErrorCode.invalidMove));
      return;
    }
    res = gameState.makeMove(aiMove.value!, inputs.enginePlayer);
    if (res.isFailure) {
      log('Engine move failed: ${res.errorCode}');
      _appendErrorResult(res);
      return;
    }

    log(
      'Engine move successful: column=${aiMove.value}, enginePlayer=${inputs.enginePlayer}',
    );
    _outputs.outputs.add(Connect4NewBoardOutput(gameState: gameState));
    if (gameState.isGameOver) {
      log('Game over: winner=${gameState.winner}, isDraw=${gameState.isDraw}');
      _outputs.outputs.add(
        TurnBasedGameGameOverFsmOutput(
          winner: gameState.winner,
          isDraw: gameState.isDraw,
        ),
      );
    }
  }

  void _processUpdateTime() {
    _processNextGameTimeout();
    _processEngineMoveNotification();
  }

  void _processNextGameTimeout() {
    if (gameState.nextGameTimeUtc == null) return;
    if (gameState.nowUtc.isBefore(gameState.nextGameTimeUtc!)) return;

    _context.addStartGameOutput = true;

    if (gameState.currentPlayer != gameState.enginePlayer) return;

    _context.addDoEngineMoveOutput = true;
  }

  void _processEngineMoveNotification() {
    if (gameState.engineMoveTimeUtc == null) return;
    if (gameState.nowUtc.isBefore(gameState.engineMoveTimeUtc!)) return;

    _context.addDoEngineMoveOutput = true;
  }

  void _processUpdateContext() {
    if (_context.addStartGameOutput) {
      log(
        '[FSM] Transition: setupNextGame called, prevState=${gameState.toString()}',
      );
      gameState.setupNextGame();
      _updateEngineDifficulty();
      log(
        '[FSM] Transition: after setupNextGame, newState=${gameState.toString()}',
      );
      _outputs.outputs.add(TurnBasedGameStartGameFsmOutput(gameState.configuration));
    }

    if (_context.addDoEngineMoveOutput) {
      log(
        '[FSM] Transition: DoEngineMoveOutput triggered, state=${gameState.toString()}',
      );
      _outputs.outputs.add(Connect4DoEngineMoveOutput());
    }
  }

  void _updateEngineDifficulty() {
    if (gameState.configuration.difficulty ==
        gameState.nextGameEngineDifficulty) {
      return;
    }
    log(
      '[FSM] Updating engine difficulty from ${gameState.configuration.difficulty} to ${gameState.nextGameEngineDifficulty}',
    );
    gameState.configuration.difficulty = gameState.nextGameEngineDifficulty;
    _engine = Connect4EngineFactory.createEngine(
      gameState.configuration.difficulty,
    );
  }

  DateTime? _getNextTimeout() {
    DateTime? soonestNextTimeout;

    void updateSoonestNextTimeout(DateTime? potentialNextTimeout) {
      if (potentialNextTimeout == null) return;
      if (soonestNextTimeout == null ||
          potentialNextTimeout.isBefore(soonestNextTimeout!)) {
        soonestNextTimeout = potentialNextTimeout;
      }
    }

    updateSoonestNextTimeout(gameState.nextGameTimeUtc);
    updateSoonestNextTimeout(gameState.engineMoveTimeUtc);

    return soonestNextTimeout;
  }

  void _appendErrorOutput(ResultErrorCode errorCode) => _outputs.outputs.add(
    Connect4ErrorOutput(results: Result.failure(errorCode)),
  );

  void _appendErrorResult(Result res) =>
      _outputs.outputs.add(Connect4ErrorOutput(results: res));
}
