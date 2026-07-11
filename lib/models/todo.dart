import 'dart:convert';

class Todo {
  int id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  String category;
  int sortOrder;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.category = 'Inbox',
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'category': category,
      'sortOrder': sortOrder,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dueDate']) : null,
      category: map['category'] ?? 'Inbox',
      sortOrder: map['sortOrder']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));
}
