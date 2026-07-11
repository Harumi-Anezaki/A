import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'database_provider.dart';

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TodoListNotifier(prefs);
});

class TodoListNotifier extends StateNotifier<List<Todo>> {
  final SharedPreferences _prefs;

  TodoListNotifier(this._prefs) : super([]) {
    _loadTodos();
  }

  void _loadTodos() {
    final List<String>? todosJson = _prefs.getStringList('todos');
    if (todosJson != null) {
      final todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      todos.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      state = todos;
    }
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    final List<String> todosJson = todos.map((todo) => todo.toJson()).toList();
    await _prefs.setStringList('todos', todosJson);
  }

  void addTodo(String title, String category, DateTime? dueDate) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      category: category,
      dueDate: dueDate,
      sortOrder: state.length,
    );

    state = [...state, newTodo];
    _saveTodos(state);
  }

  void updateTodo(Todo updatedTodo) {
    state = state.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList();
    _saveTodos(state);
  }

  void deleteTodo(int id) {
    state = state.where((todo) => todo.id != id).toList();
    _saveTodos(state);
  }

  void reorder(int oldIndex, int newIndex) {
    final todos = [...state];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = todos.removeAt(oldIndex);
    todos.insert(newIndex, item);

    // Update sortOrder
    for (int i = 0; i < todos.length; i++) {
      todos[i].sortOrder = i;
    }

    state = todos;
    _saveTodos(state);
  }
}
