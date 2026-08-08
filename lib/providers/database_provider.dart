import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

// Database provider
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Database initialization provider
final databaseInitializedProvider = FutureProvider<bool>((ref) async {
  final database = ref.watch(databaseProvider);
  try {
    await database.database;
    return true;
  } catch (e) {
    return false;
  }
});