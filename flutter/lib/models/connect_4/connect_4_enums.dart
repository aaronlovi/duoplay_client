/// An enumeration to represent the state of each square on the Connect 4 board.
enum Connect4SquareState {
  empty, // The square is empty
  red,   // The square is occupied by a red chip
  yellow // The square is occupied by a yellow chip
}

enum Connect4FSMState {
  idle,
  playing,
  gameOver,
}

enum Connect4FSMEvent {
  startGame,
  endGame,
  resetGame,
}

extension Connect4SquareStateExtensions on Connect4SquareState {
  String toShortString() {
    switch (this) {
      case Connect4SquareState.empty:
        return '';
      case Connect4SquareState.red:
        return 'red';
      case Connect4SquareState.yellow:
        return 'yellow';
    }
  }

  Connect4SquareState getOpponent() {
    switch (this) {
      case Connect4SquareState.empty:
        return Connect4SquareState.empty;
      case Connect4SquareState.red:
        return Connect4SquareState.yellow;
      case Connect4SquareState.yellow:
        return Connect4SquareState.red;
    }
  }
}
