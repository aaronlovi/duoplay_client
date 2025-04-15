import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String initialDifficulty;
  final void Function(String) onDifficultyChanged;

  const SettingsScreen({
    super.key,
    required this.initialDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
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
                  widget.onDifficultyChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
