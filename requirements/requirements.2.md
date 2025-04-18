# Connect 4 Requirements (Flutter Client)

| Requirement id | Description | Status |
|----------------|-------------|--------|
| **C.1** | Integrate Connect 4 into the existing Flutter games app. | Pending |
| **C.1.1** | Add a **game‑picker list item** for “Connect 4” with icon, title, and subtitle. Tapping it navigates to the new game screen. | Complete |
| **C.1.1.1** | Refactor the game‑picker list so new games can be registered via a data model rather than hard‑coding each tile. | Complete |
| **C.1.2** | Create **`connect4_game_screen.dart`** that hosts the board, status bar, and a “Settings” text button. | Pending |
| **C.1.2.1** | Build the **board UI & animation** layer. | Pending |
| **C.1.2.1.1** | Implement a reusable stateless `Connect4Board` widget (7 × 6 grid, no animation). | Complete |
| **C.1.2.1.1.1** | Create a 7 × 6 grid layout using `GridView` or `Table`. | Complete |
| **C.1.2.1.1.2** | Add placeholder cells to represent empty slots. | Complete |
| **C.1.2.1.1.3** | Ensure the widget is stateless and reusable. | Complete |
| **C.1.2.1.2** | Add chip‑drop animation with `AnimatedPositioned` (60 fps smooth). | Pending |
| **C.1.2.1.2.1** | Implement a method to determine the target position for a chip. | Complete |
| **C.1.2.1.2.2** | Add `AnimatedPositioned` to animate the chip's movement. | Complete |
| **C.1.2.1.3** | Implement win‑line highlight overlay (glow or pulse). | Pending |
| **C.1.2.1.3.1** | Define a method to calculate the winning line's coordinates. | Pending |
| **C.1.2.1.3.2** | Overlay a visual effect (e.g., glow or pulse) on the winning line. | Pending |
| **C.1.2.1.3.3** | Test the overlay for responsiveness and clarity. | Pending |
| **C.1.3** | Implement **`connect4_game_state.dart`** to manage board state and rules. | Pending |
| **C.1.3.1** | Provide helper methods: `isLegalMove(col)`, `applyMove(col)`, `getWinner()`, `isDraw()`. | Complete |
| **C.1.3.2** | Create unit tests for Connect 4 game logic methods: `isLegalMove`, `applyMove`, `getWinner`, and `isDraw`. Cover edge cases such as full columns, diagonal wins, and draw scenarios. | Pending |
| **C.1.3.3** | Optimize `getWinner()` using pre‑computed line masks or bitboards. | Pending |
| **C.1.3.4** | Encode board as **bitboards** (two `int64` values) for AI speed. | Pending |
| **C.1.3.5** | Add `hash()` and `clone()` helpers for AI transposition tables. | Pending |
| **C.1.4** | Introduce a finite‑state machine **`connect4_fsm.dart`** mirroring the tic‑tac‑toe FSM. | Pending |
| **C.1.4.1** | Emit `GameStateChanged` events to the UI layer for smooth animation triggers. | Pending |
| **C.1.5** | Build **AI engines** for three difficulty levels, exposed through `connect4_engine_factory.dart`. | Pending |
| **C.1.5.1** | *Beginner*: random legal column; if a winning move exists, take it. | Pending |
| **C.1.5.2** | *Intermediate*: winning move → block opponent win → random. | Pending |
| **C.1.5.3** | *Expert*: minimax with alpha‑beta pruning and iterative deepening. | Pending |
| **C.1.5.3.1** | Implement static board evaluator (center weighting, two‑in‑a‑row, etc.). | Pending |
| **C.1.5.3.2** | Add minimax + alpha‑beta (fixed depth). | Pending |
| **C.1.5.3.3** | Add iterative deepening with time cap (≤ 500 ms). | Pending |
| **C.1.5.3.4** | Add transposition table with Zobrist hashing. | Pending |
| **C.1.5.4** | Place engine code in `ai/connect4/` directory mirroring tic‑tac‑toe structure. | Pending |
| **C.1.6** | **Settings screen** (`connect4_settings_screen.dart`) accessible via a “Settings” button on the game screen. | Pending |
| **C.1.6.1** | Allow users to pick AI difficulty (Beginner, Intermediate, Expert) with a segmented button. | Pending |
| **C.1.6.2** | Add integer pickers (0 – 10 s) for **time between moves** and **time between games**. | Pending |
| **C.1.6.3** | Persist all Connect 4 settings using `SharedPreferences`. | Pending |
| **C.1.6.4** | Changing settings mid‑game applies next game only; show a toast summarizing current vs. next engine. | Pending |
| **C.1.6.5** | Provide a settings **migration routine** to apply sensible defaults on first run or after app update. | Pending |
| **C.1.7** | Display a **status bar** showing: engine name, player chip color (Red/Yellow), and move timer countdown (if enabled). | Pending |
| **C.1.8** | Add detailed **logging** for FSM transitions and AI decisions. | Pending |
| **C.1.8.1** | Define FSM transition log wrapper (suppressed in `kReleaseMode`). | Pending |
| **C.1.8.2** | Emit AI decision log as JSON blob per move (board hash, depth, chosen column, eval score). | Pending |
| **C.1.9** | Provide **unit tests** using `flutter_test`. | Pending |
| **C.1.9.1** | Illegal column selection (full column). | Pending |
| **C.1.9.2** | All four win directions, including edge diagonals. | Pending |
| **C.1.9.3** | Draw detection on a completely filled board. | Pending |
| **C.1.9.4** | AI correctness: Beginner never forfeits immediate win; Expert never misses forced win up to depth limit. | Pending |
| **C.1.9.5** | **Golden test** for chip‑drop animation timing and visual regression. | Pending |
| **C.1.9.6** | **Performance test**: Expert AI returns a move in ≤ 500 ms on mid‑range device profile. | Pending |
| **C.2** | Ensure seamless coexistence of Tic‑Tac‑Toe and Connect 4. | Pending |
| **C.2.1** | Refactor `EngineFactory` to return engines by `(GameType, Difficulty)` enum pair. | Pending |
| **C.2.2** | Ensure navigation back from any game disposes timers/streams to avoid leaks. | Pending |
| **C.2.3** | Maintain separate shared‑preferences keys (`ttt_*`, `c4_*`) to avoid cross‑game clashes. | Pending |
| **C.2.4** | Explicit **resource cleanup**: add sub‑task in every `State` class `dispose()` to cancel timers/streams. | Pending |
| **C.3** | Performance & UX polish. | Pending |
| **C.3.1** | Keep Expert‑AI move time ≤ 500 ms on mid‑range devices. | Pending |
| **C.3.1.1** | Optimize evaluator and pruning parameters for mobile targets. | Pending |
| **C.3.2** | Support **dark mode**: board and chips adapt to current `ThemeData.brightness`. | Pending |
| **C.3.2.1** | Define color tokens in one theme extension (`GameColors`) instead of hard‑coding. | Pending |
| **C.3.3** | Provide haptic feedback on chip drop and win events using `HapticFeedback`. | Pending |
| **C.3.4** | **Accessibility**: add semantics labels, high‑contrast outlines, and keyboard focus traversal for desktop/web. | Pending |
| **C.3.5** | **Localization** via `intl`: all user‑facing strings and timer formatting ready for i18n. | Pending |
