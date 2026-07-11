import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/todo.dart';
import 'database_provider.dart';

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  final isar = ref.watch(databaseProvider);
  return TodoListNotifier(isar);
});

class TodoListNotifier extends StateNotifier<List<Todo>> {
  final Isar _isar;

  TodoListNotifier(this._isar) : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _isar.todos.where().sortBySortOrder().findAll();
    state = todos;
  }

  Future<void> addTodo(String title, String category, DateTime? dueDate) async {
    final newTodo = Todo()
      ..title = title
      ..category = category
      ..dueDate = dueDate
      ..sortOrder = state.length;

    await _isar.writeTxn(() async {
      await _isar.todos.put(newTodo);
    });
    await _loadTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await _isar.writeTxn(() async {
      await _isar.todos.put(todo);
    });
    await _loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await _isar.writeTxn(() async {
      await _isar.todos.delete(id);
    });
    await _loadTodos();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final todos = [...state];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = todos.removeAt(oldIndex);
    todos.insert(newIndex, item);

    // Update sortOrder in DB
    await _isar.writeTxn(() async {
      for (int i = 0; i < todos.length; i++) {
        todos[i].sortOrder = i;
        await _isar.todos.put(todos[i]);
      }
    });

    state = todos;
  }
}
