import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/add_edit_todo_dialog.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['Inbox', 'Work', 'Personal', 'Shopping'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditDialog([Todo? todo]) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditTodoDialog(
          todo: todo,
          onSave: (title, category, dueDate) {
            if (todo == null) {
              ref.read(todoListProvider.notifier).addTodo(title, category, dueDate);
            } else {
              todo.title = title;
              todo.category = category;
              todo.dueDate = dueDate;
              ref.read(todoListProvider.notifier).updateTodo(todo);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoListProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final categoryTodos = todos.where((t) => t.category == category).toList();

          if (categoryTodos.isEmpty) {
            return Center(
              child: Text(
                'No tasks in $category',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryTodos.length,
            onReorder: (oldIndex, newIndex) {
              final oldGlobalIndex = todos.indexOf(categoryTodos[oldIndex]);
              final newGlobalIndex = todos.indexOf(categoryTodos[newIndex < categoryTodos.length ? newIndex : newIndex - 1]);
              ref.read(todoListProvider.notifier).reorder(oldGlobalIndex, newIndex < categoryTodos.length ? newGlobalIndex : newGlobalIndex + 1);
            },
            itemBuilder: (context, index) {
              final todo = categoryTodos[index];
              return Dismissible(
                key: ValueKey(todo.id),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                  } else {
                    todo.isCompleted = !todo.isCompleted;
                    ref.read(todoListProvider.notifier).updateTodo(todo);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (val) {
                        todo.isCompleted = val ?? false;
                        ref.read(todoListProvider.notifier).updateTodo(todo);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: todo.dueDate != null
                        ? Text(
                            'Due: ${DateFormat('MMM d, y - h:mm a').format(todo.dueDate!)}',
                            style: TextStyle(
                              color: todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                    onTap: () => _showAddEditDialog(todo),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
