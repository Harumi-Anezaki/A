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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have ${todos.where((t) => !t.isCompleted).length} pending tasks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.colorScheme.primary,
                ),
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                dividerColor: Colors.transparent,
                tabs: _categories.map((c) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  final categoryTodos = todos.where((t) => t.category == category).toList();

                  if (categoryTodos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 80, color: theme.disabledColor.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'All caught up in $category!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.disabledColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.check, color: Colors.white, size: 28),
                        ),
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
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
                          key: ValueKey('card_${todo.id}'),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: todo.isCompleted ? theme.cardColor.withOpacity(0.6) : theme.cardColor,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: todo.isCompleted,
                                  activeColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
                                  onChanged: (val) {
                                    todo.isCompleted = val ?? false;
                                    ref.read(todoListProvider.notifier).updateTodo(todo);
                                  },
                                ),
                              ),
                              title: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                  color: todo.isCompleted ? theme.disabledColor : theme.textTheme.titleMedium?.color,
                                ),
                                child: Text(todo.title),
                              ),
                              subtitle: todo.dueDate != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted
                                                ? Colors.redAccent
                                                : theme.disabledColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM d, y - h:mm a').format(todo.dueDate!),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted
                                                  ? Colors.redAccent
                                                  : theme.disabledColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                              trailing: Icon(Icons.drag_indicator, color: theme.disabledColor.withOpacity(0.5)),
                              onTap: () => _showAddEditDialog(todo),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
