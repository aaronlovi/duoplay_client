import 'package:flutter/material.dart';

/// A reusable, generic game grid widget for turn-based games.
/// Supports dynamic grid sizes and custom cell rendering.
class GameGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final double spacing;
  final Widget Function(BuildContext context, int index) cellBuilder;
  final double? aspectRatio;

  const GameGrid({
    super.key,
    required this.rows,
    required this.columns,
    required this.cellBuilder,
    this.spacing = 4.0,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: rows * columns,
      itemBuilder: (context, index) => cellBuilder(context, index),
    );
    if (aspectRatio != null) {
      return AspectRatio(aspectRatio: aspectRatio!, child: grid);
    }
    return grid;
  }
}
