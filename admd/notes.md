# Lab 3 presentation notes

## Task I: Todo screen

- `TodoScreen` is a `StatefulWidget`: its State holds the todo list.
- `Todo` stores a title and a `ValueNotifier<bool>` for completion.
- `ListView.builder` builds rows lazily as they are needed.
- `TodoTile` is a reusable `StatelessWidget` receiving a todo through its constructor.
- Each tile contains a `Card` and `CheckboxListTile`.
- `Expanded` gives the list the remaining height below the input.

## State updates

- Adding calls `setState()` to rebuild the screen with the updated list.
- Toggling updates `todo.done.value`. Only that tile's `ValueListenableBuilder` subtree rebuilds.
- Input is trimmed, blank tasks are ignored, and the field clears after adding.

## Scrolling and cleanup

- After layout, `addPostFrameCallback` calls `animateTo()` to scroll toward the bottom over 300 ms.
- Scrolling is visible only when the list exceeds the available height. Card insertion itself is not animated.
- `dispose()` releases the text controller, scroll controller, and todo notifiers.
- Tasks exist only in memory: restarting the app clears them.

## Demo

1. Add two tasks; check and uncheck one.
2. Try adding spaces only.
3. Fill the screen, then add another task to demonstrate scrolling.
4. Show `_add()`, `TodoTile`, and its `ValueListenableBuilder` in the code.

## Task II: Swipeable rows

- `Dismissible` wraps each `TodoTile`; swipe left to delete (right-to-left layouts reverse this).
- `ValueKey(todo.id)` keeps row identity stable when other rows disappear. An index would change after deletion.
- A red background with a delete icon appears during the swipe.
- `onDismissed` removes the todo using `setState()`.
- The snackbar's Undo restores the same todo, including its checked state and list order.
- Removed todos' notifiers are disposed after the undo opportunity ends.
- Demo: delete a checked task from the middle, then Undo.

## Task III: DevTools

### Bug 1: Off-by-one (investigated and fixed)

- Opened Inspector and used the debugger's breakpoint, Watch, and Call Stack.
- Adding one todo produced `i = 1`, `_items.length = 1`, and a `RangeError`.
- A one-item list has only index `0`. The `<=` loop ran one iteration too far.
- Fix: `i < _items.length`.
- Pausing in the debugger suspends the app so variables can be inspected.

Still to do: missing state notification and null access exercises.
