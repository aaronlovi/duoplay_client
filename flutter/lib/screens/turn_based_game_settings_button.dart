import 'package:flutter/material.dart';

/// A reusable settings button widget for turn-based games.
class SettingsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final ButtonStyle? style;

  const SettingsButton({
    super.key,
    required this.onPressed,
    this.label = 'Settings',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
