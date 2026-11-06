import 'package:flutter/material.dart';

class Todo {
  Todo(this.title) : id = _nextId++;

  static int _nextId = 0;
  final int id;

  final String title;
  final done = ValueNotifier<bool>(false);
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _items = <Todo>[];
  final _removed = <Todo>{};
  final _input = TextEditingController();
  final _scroll = ScrollController();

  void _add() {
    final title = _input.text.trim();
    if (title.isEmpty) return;

    setState(() => _items.add(Todo(title)));
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    debugPrint('Completed todos: ${_countDone()}');
  }

  // Lab 3, Task III - Bug 1 fixed: indices must stay below the length.
  int _countDone() {
    var done = 0;
    // Bug <=; should be <
    for (var i = 0; i <= _items.length; i++) {
      done += _items[i].done.value ? 1 : 0; // breakpoint
    }
    return done;
  }

  void _remove(Todo todo) {
    setState(() {
      _items.removeWhere((item) => item.id == todo.id);
      _removed.add(todo);
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text('Deleted "${todo.title}"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                if (!mounted || !_removed.remove(todo)) return;
                setState(() {
                  // IDs preserve insertion order, even after consecutive deletes.
                  final next = _items.indexWhere((item) => item.id > todo.id);
                  _items.insert(next < 0 ? _items.length : next, todo);
                });
              },
            ),
          ),
        )
        .closed
        .then((_) {
          if (mounted && _removed.remove(todo)) todo.done.dispose();
        });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    for (final todo in [..._items, ..._removed]) {
      todo.done.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _input,
                decoration: const InputDecoration(
                  labelText: 'New todo',
                  hintText: 'What do you need to do?',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('No todos yet. Add your first task.'),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final todo = _items[index];
                        return Dismissible(
                          key: ValueKey(todo.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _remove(todo),
                          background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: TodoTile(todo: todo),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  const TodoTile({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    // Listen here so checking a todo rebuilds only this tile's contents.
    return ValueListenableBuilder<bool>(
      valueListenable: todo.done,
      builder: (context, done, child) => Card(
        child: CheckboxListTile(
          value: done,
          onChanged: (value) => todo.done.value = value ?? false,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
