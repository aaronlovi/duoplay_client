# Requirements

| Requirement id | Description | Status |
|----------------|-------------|--------|
| G.1 | Review the Flutter tic-tac-toe implementation. Suggest improvements | Complete |
| G.1.1 | Refactor lengthy methods in `tic_tac_toe_game_state.dart` into smaller, reusable functions for better readability and maintainability. | Complete |
| G.1.1.1 | Extract helper functions from `makeMove` in `tic_tac_toe_game_state.dart` to improve readability. | Complete |
| G.1.1.2 | Refactor `getWinner` in `tic_tac_toe_game_state.dart` to use precomputed data structures for optimization. | Complete |
| G.1.2 | Enhance tic-tac-toe by allowing to play against an AI at Beginner and Expert level. Both levels will currently play against the same engine. | Complete |
| G.1.2.1 | Implement a minimax algorithm with alpha-beta pruning in `tic_tac_toe_basic_engine.dart`. | Complete |
| G.1.2.2 | Add configuration options to toggle between basic and advanced AI in `tic_tac_toe_basic_engine.dart`. | Complete |
| G.1.3 | Enhance the AI engine in `tic_tac_toe_basic_engine.dart` to use a more advanced algorithm like minimax with alpha-beta pruning. This is the "expert" level. Playing against beginner level will play against the original engine. | Complete |
| G.1.3.1 | Write unit tests for invalid moves in `tic_tac_toe_game_state.dart`. | Complete |
| G.1.3.2 | Write unit tests for simultaneous win/draw conditions in `tic_tac_toe_game_state.dart`. | Complete |
| G.1.4 | Add comprehensive unit tests to cover edge cases, such as invalid moves or simultaneous win/draw conditions. | Complete |
| G.1.4.1 | Add detailed logging for FSM transitions in `tic_tac_toe_fsm.dart`. | Complete |
| G.1.4.2 | Add detailed logging for AI decisions in `tic_tac_toe_fsm.dart`. | Complete |
| G.1.5 | Optimize the `getWinner` logic in `tic_tac_toe_game_state.dart` with precomputed data structures or caching. | Completed |
| G.1.6 | Add detailed logging for FSM transitions and AI decisions in `tic_tac_toe_fsm.dart` to aid debugging and analysis. | Completed |
| G.1.7 | Implement beginner, intermediate, and expert AI modes for tic-tac-toe. | Complete |
| G.1.7.1 | Beginner mode: Try to make immediately winning moves, then make a random legal move. | Complete |
| G.1.7.2 | Intermediate mode: Try to make immediately winning moves, block opponent's immediately winning moves, then make a random legal move. | Complete |
| G.1.7.3 | Expert mode: Use perfect lookahead to make the best move. | Complete |
| G.1.8 | Add a settings screen or menu to allow users to select the AI difficulty level (Beginner, Intermediate, Expert). | Complete |
| G.1.8.1 | Store the selected difficulty level in persistent storage (e.g., shared preferences). | Complete |
| G.1.8.2 | Use the stored difficulty level to initialize the appropriate engine using the `EngineFactory`. | Complete |
