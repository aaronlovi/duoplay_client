import 'package:duoplay/models/result.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_inputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_configuration.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_game_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_output_container.dart'; // For logging with `log`

class TTTFsmUpdateContext {
  bool addStartGameOutput;
  bool addDoEngineMoveOutput;

  TTTFsmUpdateContext()
    : addStartGameOutput = false,
      addDoEngineMoveOutput = false;

  void clear() {
    addStartGameOutput = false;
    addDoEngineMoveOutput = false;
  }
}

class TicTacToeFSM {
  TicTacToeGameState gameState;
  final TicTacToeOutputContainer _outputs;
  final TTTFsmUpdateContext _context;

  TicTacToeFSM(TTTGameConfiguration configuration)
    : gameState = TicTacToeGameState.initial(configuration),
      _outputs = TicTacToeOutputContainer(outputs: <TTTOutputBase>[]),
      _context = TTTFsmUpdateContext();

  List<TicTacToeCellState> get board => gameState.board;
  bool get isPlayerXEngine =>
      gameState.configuration.enginePlayer == TicTacToeCellState.x;
  bool get isPlayerOEngine =>
      gameState.configuration.enginePlayer == TicTacToeCellState.o;
  bool get isHumanPlayerToMove => gameState.isHumanPlayerToMove;
  TicTacToeCellState get humanPlayer => gameState.humanPlayer;
  TicTacToeCellState get enginePlayer => gameState.enginePlayer;

  void update(TicTacToeInputBase inputs, TicTacToeOutputContainer outputs) {
    _outputs.clear();
    _context.clear();
    outputs.clear();
    gameState.nowUtc = inputs.nowUtc;

    if (inputs is TicTacToeGameConfigInput) {
      _processGameConfiguration(inputs);
    } else if (inputs is TicTacToePlayerMoveInput) {
      _processPlayerMove(inputs);
    } else if (inputs is TicTacToeEngineMoveInput) {
      _processEngineMove(inputs);
    } else if (inputs is TicTacToeUpdateTime) {
      // Nothing to do here
    }

    _processUpdateTime();
    _processUpdateContext();

    outputs.outputs.addAll(_outputs.outputs);
    outputs.nextTimeout = _getNextTimeout();
  }

  // Reset the game board with the new configuration
  void _processGameConfiguration(TicTacToeGameConfigInput inputs) {
    gameState.processNewGameConfiguration(inputs.configuration, inputs.nowUtc);
    _outputs.outputs.add(TTTStartGameOutput(inputs.configuration));
  }

  void _processPlayerMove(TicTacToePlayerMoveInput inputs) {
    if (inputs.player == gameState.configuration.enginePlayer ||
        inputs.player == TicTacToeCellState.empty) {
      _appendErrorOutput(ResultErrorCode.invalidMove);
      return;
    }

    Result res = gameState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      _appendErrorResult(res);
      return;
    }

    res = gameState.makeMove(inputs.index, inputs.player);
    if (res.isFailure) {
      _appendErrorResult(res);
      return;
    }

    _outputs.outputs.add(TTTNewBoardOutput(gameState: gameState));
    if (gameState.isGameOver) {
      _outputs.outputs.add(
        TTTGameOverOutput(winner: gameState.winner, isDraw: gameState.isDraw),
      );
    }
  }

  void _processEngineMove(TicTacToeEngineMoveInput inputs) {
    if (inputs.enginePlayer != gameState.configuration.enginePlayer ||
        inputs.enginePlayer == TicTacToeCellState.empty) {
      _appendErrorOutput(ResultErrorCode.invalidMove);
      return;
    }

    Result res = gameState.isLegalPositionReadyForMove();
    if (res.isFailure) {
      _appendErrorResult(res);
      return;
    }

    res = gameState.makeMove(inputs.index, inputs.enginePlayer);
    if (res.isFailure) {
      _appendErrorResult(res);
      return;
    }

    _outputs.outputs.add(TTTNewBoardOutput(gameState: gameState));
    if (gameState.isGameOver) {
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
      gameState.setupNextGame();
      _outputs.outputs.add(TTTStartGameOutput(gameState.configuration));
    }

    if (_context.addDoEngineMoveOutput) {
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
