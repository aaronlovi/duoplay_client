import 'dart:developer';

import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_contract.dart';
import 'package:duoplay/engines/tic_tac_toe/tic_tac_toe_engine_factory.dart';
import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_inputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart'; // For logging with `log`

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
  String _currentEngineDifficulty;
  String _nextEngineDifficulty;

  TTTFsm(TTTGameConfiguration configuration)
    : gameState = TicTacToeGameState.initial(configuration),
      _outputs = TTTOutputContainer(outputs: <TTTOutputBase>[]),
      _context = _TTTFsmUpdateContext(),
      _currentEngineDifficulty = configuration.difficulty,
      _nextEngineDifficulty = configuration.difficulty {
    _engine = TTTEngineFactory.createEngine(configuration.difficulty);
  }

  List<TTTCellState> get board => gameState.board;
  bool get isPlayerXEngine =>
      gameState.configuration.enginePlayer == TTTCellState.x;
  bool get isPlayerOEngine =>
      gameState.configuration.enginePlayer == TTTCellState.o;
  bool get isHumanPlayerToMove => gameState.isHumanPlayerToMove;
  TTTCellState get humanPlayer => gameState.humanPlayer;
  TTTCellState get enginePlayer => gameState.enginePlayer;

  void update(TTTInputBase inputs, TTTOutputContainer outputs) {
    final prevState = gameState.toString();
    final inputType = inputs.runtimeType.toString();
    log(
      '[FSM] Transition: prevState=$prevState, inputType=$inputType, input=$inputs',
    );
    _outputs.clear();
    _context.clear();
    outputs.clear();
    gameState.nowUtc = inputs.nowUtc;

    if (inputs is TTTGameConfigInput) {
      _processGameConfiguration(inputs);
    } else if (inputs is TTTPlayerMoveInput) {
      _processPlayerMove(inputs);
    } else if (inputs is TTTEngineMoveInput) {
      _processEngineMove(inputs);
    } else if (inputs is TTTUpdateTime) {
      // Nothing to do here
    }

    _processUpdateTime();
    _processUpdateContext();

    outputs.outputs.addAll(_outputs.outputs);
    outputs.nextTimeout = _getNextTimeout();
    log('[FSM] Transition: newState=${gameState.toString()}');
  }

  void updateEngineDifficulty(String newDifficulty) {
    _nextEngineDifficulty = newDifficulty;
  }

  // Reset the game board with the new configuration
  void _processGameConfiguration(TTTGameConfigInput inputs) {
    log('Processing game configuration: ${inputs.configuration}');
    gameState.processNewGameConfiguration(inputs.configuration, inputs.nowUtc);
    // Use the next engine difficulty for the new game
    _currentEngineDifficulty = _nextEngineDifficulty;
    _engine = TTTEngineFactory.createEngine(_currentEngineDifficulty);
    _outputs.outputs.add(TTTStartGameOutput(inputs.configuration));
  }

  void _processPlayerMove(TTTPlayerMoveInput inputs) {
    log(
      'Processing player move: index=${inputs.index}, player=${inputs.player}',
    );
    if (inputs.player == gameState.configuration.enginePlayer ||
        inputs.player == TTTCellState.empty) {
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
        TTTGameOverOutput(winner: gameState.winner, isDraw: gameState.isDraw),
      );
    }
  }

  void _processEngineMove(TTTEngineMoveInput inputs) {
    log(
      'Processing engine move: index=${inputs.index}, enginePlayer=${inputs.enginePlayer}',
    );
    if (inputs.enginePlayer != gameState.configuration.enginePlayer ||
        inputs.enginePlayer == TTTCellState.empty) {
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
        TTTGameOverOutput(winner: gameState.winner, isDraw: gameState.isDraw),
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
      log(
        '[FSM] Transition: after setupNextGame, newState=${gameState.toString()}',
      );
      _outputs.outputs.add(TTTStartGameOutput(gameState.configuration));
    }

    if (_context.addDoEngineMoveOutput) {
      log(
        '[FSM] Transition: DoEngineMoveOutput triggered, state=${gameState.toString()}',
      );
      _outputs.outputs.add(TTTDoEngineMoveOutput());
    }
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
      _outputs.outputs.add(TTTErrorOutput(results: Result.failure(errorCode)));

  void _appendErrorResult(Result res) =>
      _outputs.outputs.add(TTTErrorOutput(results: res));
}
