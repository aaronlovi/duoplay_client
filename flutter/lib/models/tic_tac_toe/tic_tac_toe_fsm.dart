import 'dart:developer';

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_factory.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_inputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_configuration.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_fsm_outputs.dart';
import 'package:duoplay/models/turn-based-game/turn_based_game_utils.dart';

class _TTTFsmUpdateContext {
  bool addStartGameOutput;
  bool addDoEngineMoveOutput;

  _TTTFsmUpdateContext()
    : addStartGameOutput = false,
      addDoEngineMoveOutput = false;

  void clear() {
    addStartGameOutput = false;
    addDoEngineMoveOutput = false;
  }
}

class TTTFsm {
  TicTacToeGameState gameState;
  final TTTOutputContainer _outputs;
  final _TTTFsmUpdateContext _context;
  late TTTEngineContract _engine;

  TTTFsm(TurnBasedGameConfiguration configuration)
    : gameState = TicTacToeGameState.initial(configuration),
      _outputs = TTTOutputContainer(outputs: <TurnBasedGameFsmOutputBase>[]),
      _context = _TTTFsmUpdateContext() {
    _engine = TTTEngineFactory.createEngine(configuration.difficulty);
  }

  List<TurnBasedGameCellState> get board => gameState.board;
  bool get isPlayerXEngine =>
      gameState.configuration.enginePlayer == TurnBasedGameCellState.player1;
  bool get isPlayerOEngine =>
      gameState.configuration.enginePlayer == TurnBasedGameCellState.player2;
  bool get isHumanPlayerToMove => gameState.isHumanPlayerToMove;
  TurnBasedGameCellState get humanPlayer => gameState.humanPlayer;
  TurnBasedGameCellState get enginePlayer => gameState.enginePlayer;
  String get nextGameDifficulty => gameState.nextGameEngineDifficulty;

  void update(TurnBasedGameFsmInputBase inputs, TTTOutputContainer outputs) {
    final prevState = gameState.toString();
    final inputType = inputs.runtimeType.toString();
    log(
      '[FSM] Transition: prevState=$prevState, inputType=$inputType, input=$inputs',
    );
    _outputs.clear();
    _context.clear();
    outputs.clear();
    gameState.nowUtc = inputs.nowUtc;

    if (inputs is TurnBasedGameConfigFsmInput) {
      _processGameConfiguration(inputs);
    } else if (inputs is TTTSettingsChangeInput) {
      _processSettingsChange(inputs);
    } else if (inputs is TurnBasedGamePlayerMoveFsmInput) {
      _processPlayerMove(inputs);
    } else if (inputs is TurnBasedGameEngineMoveFsmInput) {
      _processEngineMove(inputs);
    } else if (inputs is TurnBasedGameUpdateTimeFsmInput) {
      // Nothing to do here
    }

    _processUpdateTime();
    _processUpdateContext();

    outputs.outputs.addAll(_outputs.outputs);
    outputs.nextTimeout = _getNextTimeout();
    log('[FSM] Transition: newState=${gameState.toString()}');
  }

  void _processSettingsChange(TTTSettingsChangeInput inputs) {
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
  void _processGameConfiguration(TurnBasedGameConfigFsmInput inputs) {
    log('Processing game configuration: ${inputs.configuration}');
    gameState.processNewGameConfiguration(inputs.configuration, inputs.nowUtc);
    _updateEngineDifficulty();
    _outputs.outputs.add(TurnBasedGameStartGameFsmOutput(inputs.configuration));
  }

  void _processPlayerMove(TurnBasedGamePlayerMoveFsmInput inputs) {
    log(
      'Processing player move: index=${inputs.index}, player=${inputs.player}',
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

    res = gameState.makeMove(inputs.index, inputs.player);
    if (res.isFailure) {
      log('Move failed: ${res.errorCode}');
      _appendErrorResult(res);
      return;
    }

    log('Move successful: index=${inputs.index}, player=${inputs.player}');
    _outputs.outputs.add(TTTNewBoardOutput(gameState: gameState));
    if (gameState.isGameOver) {
      log('Game over: winner=${gameState.winner}, isDraw=${gameState.isDraw}');
      _outputs.outputs.add(
        TurnBasedGameGameOverFsmOutput(winner: gameState.winner, isDraw: gameState.isDraw),
      );
    }
  }

  void _processEngineMove(TurnBasedGameEngineMoveFsmInput inputs) {
    log(
      'Processing engine move: index=${inputs.index}, enginePlayer=${inputs.enginePlayer}',
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
      'Engine move successful: index=${aiMove.value}, enginePlayer=${inputs.enginePlayer}',
    );
    _outputs.outputs.add(TTTNewBoardOutput(gameState: gameState));
    if (gameState.isGameOver) {
      log('Game over: winner=${gameState.winner}, isDraw=${gameState.isDraw}');
      _outputs.outputs.add(
        TurnBasedGameGameOverFsmOutput(winner: gameState.winner, isDraw: gameState.isDraw),
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
      _outputs.outputs.add(TurnBasedGameDoEngineMoveFsmOutput());
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
    _engine = TTTEngineFactory.createEngine(gameState.configuration.difficulty);
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

  void _appendErrorOutput(ResultErrorCode errorCode) =>
      _outputs.outputs.add(TurnBasedGameErrorFsmOutput(results: Result.failure(errorCode)));

  void _appendErrorResult(Result res) =>
      _outputs.outputs.add(TurnBasedGameErrorFsmOutput(results: res));
}
