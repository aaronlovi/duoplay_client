class TurnBasedGameFsmUpdateContext {
  bool addStartGameOutput;
  bool addDoEngineMoveOutput;

  TurnBasedGameFsmUpdateContext()
    : addStartGameOutput = false,
      addDoEngineMoveOutput = false;

  void clear() {
    addStartGameOutput = false;
    addDoEngineMoveOutput = false;
  }
}
