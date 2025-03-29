import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_cell_state.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_error_handling.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm.dart';
import 'package:duoplay/models/tic_tac_toe/tic_tac_toe_fsm_outputs.dart';
import 'package:flutter/material.dart';

class TicTacToeGameScreen extends StatefulWidget {
  final TicTacToeFSM fsm;

  const TicTacToeGameScreen({super.key, required this.fsm});

  @override
  TicTacToeGameScreenState createState() => TicTacToeGameScreenState();
}

class TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  late TicTacToeFSM fsm;

  @override
  void initState() {
    super.initState();
    fsm = widget.fsm; // Initialize the FSM from the widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic-Tac-Toe')),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1, // Ensures the grid is square
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns for the Tic-Tac-Toe board
              crossAxisSpacing: 4, // Space between columns
              mainAxisSpacing: 4, // Space between rows
            ),
            itemCount: 9, // 3x3 grid = 9 cells
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Handle the tap using the FSM
                  final output = <TicTacToeOutput>[];
                  fsm.update(index, fsm.gameState.currentPlayer, output);

                  // Process the FSM outputs (e.g., update UI, show errors, etc.)
                  setState(() {
                    for (var item in output) {
                      if (item is TicTacToeErrorOutput) {
                        String errorMessage = ticTacToeErrorCodeToString(
                          item.results.errorCode,
                          item.results.errorParameters,
                        );
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMessage)));
                      }
                      // Handle other outputs like TicTacToeNewBoardOutput or TicTacToeGameOverOutput
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // Cell borders
                  ),
                  child: Center(
                    child: Text(
                      fsm.gameState.board[index].toShortString(),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
