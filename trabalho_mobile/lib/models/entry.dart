import 'package:hive_flutter/hive_flutter.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry {

  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int iconId;

  Entry({
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.iconId
  });
}