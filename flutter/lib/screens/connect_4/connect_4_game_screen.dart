import 'package:duoplay/engines/turn_based_game/turn_based_game_engine_contract.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_fsm_inputs.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_output_container.dart';
import 'package:duoplay/models/turn_based_game/turn_based_game_utils.dart';
import 'package:duoplay/screens/turn_based_game_screen_base.dart';
import 'package:flutter/material.dart';

class Connect4GameScreen extends StatefulWidget {
  final TurnBasedGameContainer gameObject;
  final TurnBasedGameEngineContract engine;
  final TurnBasedGameUtils gameUtils;

  const Connect4GameScreen({
    super.key,
    required this.gameObject,
    required this.engine,
    required this.gameUtils,
  });

  @override
  Connect4GameScreenState createState() => Connect4GameScreenState();
}

class Connect4GameScreenState
    extends TurnBasedGameScreenBase<Connect4GameScreen>
    with TickerProviderStateMixin {
  final Color gridColor = const Color(0xFFFFE082);
  late AnimationController _pulsingController; // For infinite pulses (engine)
  late AnimationController _humanPulseController; // For single pulse (human)

  @override
  void initState() {
    super.initState();
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Loop the animation

    _humanPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    ); // Single pulse animation
  }

  @override
  void dispose() {
    _pulsingController.dispose(); // Dispose of the infinite pulse controller
    _humanPulseController.dispose(); // Dispose of the single pulse controller
    super.dispose();
  }

  @override
  TurnBasedGameContainer get gameObject => widget.gameObject;
  @override
  TurnBasedGameEngineContract get engine => widget.engine;
  @override
  TurnBasedGameUtils get gameUtils => widget.gameUtils;
  @override
  String get appBarTitle => 'Connect 4';
  @override
  String get settingsRoute => '/connect-4/settings';
  @override
  String get settingsDifficultyKey => 'connect4_ai_difficulty';

  @override
  Widget buildGameGrid(BuildContext context) {
    final rows = gameLogic.rows;
    final columns = gameLogic.columns;

    return Center(
      child: Container(
        color: gridColor, // Set the pale yellow grid background color
        padding: const EdgeInsets.all(
          8.0,
        ), // Add padding to extend beyond cells
        child: AspectRatio(
          aspectRatio: columns / rows, // Maintain the grid's aspect ratio
          child: super.buildGameGrid(context), // Call the base grid builder
        ),
      ),
    );
  }

  @override
  int calculateAdjustedIndex(int index) {
    final column =
        index % gameLogic.columns; // Get the column from the tapped index
    final rows = gameLogic.rows;

    // Find the lowest available cell in the column
    for (int row = rows - 1; row >= 0; row--) {
      final adjustedIndex = row * gameLogic.columns + column;
      if (gameObject.board[adjustedIndex] == TurnBasedGameCellState.empty) {
        return adjustedIndex; // Return the lowest available index
      }
    }

    return -1; // No available cell in the column
  }

  @override
  Widget getCellContents(int index) {
    final cellState = gameObject.board[index];
    final isMostRecentMove = index == mostRecentMoveIndex;
    final isWinningCell = winningIndices.contains(index);

    return Container(
      decoration: BoxDecoration(
        color:
            isWinningCell
                ? Colors.greenAccent
                : Colors.white, // Highlight winning cells
        shape: BoxShape.circle,
        border: Border.all(
          color: gridColor,
          width: isWinningCell ? 4.0 : 2.0, // Thicker border for winning cells
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final tokenSize =
              constraints.biggest.shortestSide * 0.8; // Dynamic token size
          if (isMostRecentMove) {
            final isHumanMove = !gameObject.isHumanPlayerToMove;
            return _buildPulsingToken(cellState, tokenSize, isHumanMove);
          }
          return _getCellInnerContents(
            cellState,
            tokenSize,
          ); // Static token for other cells
        },
      ),
    );
  }

  Widget _getCellInnerContents(
    TurnBasedGameCellState cellState,
    double tokenSize,
  ) {
    final color = _getCellColor(cellState);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: tokenSize,
        height: tokenSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color, // Token color
        ),
      ),
    );
  }

  Widget _buildPulsingToken(
    TurnBasedGameCellState cellState,
    double tokenSize,
    bool isHumanMove,
  ) {
    final color = _getCellColor(cellState);

    // Use the appropriate animation controller
    final animation =
        isHumanMove
            ? Tween<double>(begin: 0.65, end: 0.92).animate(
              CurvedAnimation(
                parent: _humanPulseController,
                curve: Curves.easeInOut,
              ),
            )
            : Tween<double>(begin: 0.75, end: 0.95).animate(
              CurvedAnimation(
                parent: _pulsingController,
                curve: Curves.easeInOut,
              ),
            );

    return ScaleTransition(
      scale: animation,
      child: Container(
        width: tokenSize,
        height: tokenSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Color _getCellColor(TurnBasedGameCellState state) {
    switch (state) {
      case TurnBasedGameCellState.player1:
        return Colors.red; // Player 1 token color
      case TurnBasedGameCellState.player2:
        return Colors.yellow; // Player 2 token color
      default:
        return Colors.transparent; // Empty cell
    }
  }

  @override
  void handleCellTap(int index) {
    if (!gameObject.isHumanPlayerToMove) return;

    final adjustedIndex = calculateAdjustedIndex(index);
    if (adjustedIndex == -1) return; // Invalid move

    final inp = TurnBasedGamePlayerMoveFsmInput(
      index: adjustedIndex,
      player: gameObject.humanPlayer,
      nowUtc: DateTime.now().toUtc(),
    );
    TurnBasedGameOutputContainer outputs = gameObject.postInput(inp);
    setState(() {
      mostRecentMoveIndex = adjustedIndex;
      _humanPulseController.forward(
        from: 0.0,
      ); // Trigger single pulse animation
      processOutputs(outputs);
    });
  }

  @override
  Widget buildStatusBar() {
    final winner =
        winningIndices.isNotEmpty
            ? gameUtils.cellStateToShortString(
              gameObject.gameState.currentPlayer,
            )
            : 'None';

    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'Winner: $winner    Winning Indices: ${winningIndices.join(", ")}',
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
