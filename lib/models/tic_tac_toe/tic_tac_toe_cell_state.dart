enum TicTacToeCellState { empty, x, o }

extension TicTacToeCellStateExtensions on TicTacToeCellState {
  String toShortString() {
    switch (this) {
      case TicTacToeCellState.empty:
        return '';
      case TicTacToeCellState.x:
        return 'X';
      case TicTacToeCellState.o:
        return 'O';
    }
  }
}
