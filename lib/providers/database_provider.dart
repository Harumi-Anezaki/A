import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

final databaseProvider = Provider<Isar>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [TodoSchema],
    directory: dir.path,
  );
}
