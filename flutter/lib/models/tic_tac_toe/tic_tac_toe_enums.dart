enum TTTCellState { empty, x, o }

extension TTTCellStateExtensions on TTTCellState {
  String toShortString() {
    switch (this) {
      case TTTCellState.empty:
        return '';
      case TTTCellState.x:
        return 'X';
      case TTTCellState.o:
        return 'O';
    }
  }

  TTTCellState getOpponent() {
    switch (this) {
      case TTTCellState.empty:
        return TTTCellState.empty;
      case TTTCellState.x:
        return TTTCellState.o;
      case TTTCellState.o:
        return TTTCellState.x;
    }
  }
}
