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

  TicTacToeCellState getOpponent() {
    switch (this) {
      case TicTacToeCellState.empty:
        return TicTacToeCellState.empty;
      case TicTacToeCellState.x:
        return TicTacToeCellState.o;
      case TicTacToeCellState.o:
        return TicTacToeCellState.x;
    }
  }
}
