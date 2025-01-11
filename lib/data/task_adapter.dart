import 'package:hive_flutter/hive_flutter.dart';

class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime? deadline;

  @HiveField(3)
  bool isCompleted;

  Task({
    required this.title,
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
  });
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      title: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      deadline: reader.readBool() ? DateTime.parse(reader.readString()) : null,
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.deadline != null);
    if (obj.deadline != null) {
      writer.writeString(obj.deadline!.toIso8601String());
    }
    writer.writeBool(obj.isCompleted);
  }
}