import 'package:duoplay/models/turn_based_game/turn_based_game_container.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tic_tac_toe_settings_screen.dart';

class TicTacToeSettingsLoader extends StatelessWidget {
  final TurnBasedGameContainer gameContainer;

  const TicTacToeSettingsLoader({super.key, required this.gameContainer});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({String difficulty, int moveDelay, int gameDelay})>(
      future: _loadSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        return TicTacToeSettingsScreen(
          initialDifficulty: data.difficulty,
          gameContainer: gameContainer,
          initialMoveDelay: data.moveDelay,
          initialGameDelay: data.gameDelay,
        );
      },
    );
  }

  Future<({String difficulty, int moveDelay, int gameDelay})>
  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final difficulty = prefs.getString('ttt_ai_difficulty') ?? 'beginner';
    final moveDelay = prefs.getInt('ttt_move_delay') ?? 1;
    final gameDelay = prefs.getInt('ttt_game_delay') ?? 1;
    return (difficulty: difficulty, moveDelay: moveDelay, gameDelay: gameDelay);
  }
}
