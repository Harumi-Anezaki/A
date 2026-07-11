import 'package:isar/isar.dart';

part 'todo.g.dart';

@collection
class Todo {
  Id id = Isar.autoIncrement;

  late String title;
  
  bool isCompleted = false;

  DateTime? dueDate;

  String category = 'Inbox';

  int sortOrder = 0; // For reordering
}
