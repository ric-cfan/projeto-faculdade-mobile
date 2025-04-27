import 'package:hive_flutter/hive_flutter.dart';
import 'package:trabalho_mobile/models/entry.dart';

class EntriesService {
  static final _box = Hive.box<Entry>('entries');

  static Future<void> addEntry(Entry entry) async {
    await _box.add(entry);
  }

  static List<Entry> getAllEntries() {
    return _box.values.toList();
  }

  static Future<void> deleteEntry(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> updateEntry(int index, Entry newEntry) async {
    await _box.putAt(index, newEntry);
  }

  static int get count => _box.length;
}
