import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicTacToeSettingsScreen extends StatefulWidget {
  final String initialDifficulty;
  final int initialMoveDelay;
  final int initialGameDelay;

  const TicTacToeSettingsScreen({
    super.key,
    required this.initialDifficulty,
    this.initialMoveDelay = 1,
    this.initialGameDelay = 1,
  });

  @override
  State<TicTacToeSettingsScreen> createState() =>
      _TicTacToeSettingsScreenState();
}

class _TicTacToeSettingsScreenState extends State<TicTacToeSettingsScreen> {
  late String _selectedDifficulty;
  late int _moveDelay;
  late int _gameDelay;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _moveDelay = widget.initialMoveDelay;
    _gameDelay = widget.initialGameDelay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Difficulty', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _selectedDifficulty,
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'expert', child: Text('Expert')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDifficulty = value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Time between moves (seconds)',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<int>(
              value: _moveDelay,
              items: List.generate(
                11,
                (i) => DropdownMenuItem(value: i, child: Text(i.toString())),
              ),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _moveDelay = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('ttt_move_delay', value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Time between games (seconds)',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<int>(
              value: _gameDelay,
              items: List.generate(
                11,
                (i) => DropdownMenuItem(value: i, child: Text(i.toString())),
              ),
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _gameDelay = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('ttt_game_delay', value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
