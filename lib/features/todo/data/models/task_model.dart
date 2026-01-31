import 'package:hive/hive.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';

/// Hive model for Task with manual TypeAdapter.
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final DateTime? time;

  @HiveField(5)
  final bool isLunarCalendar;

  @HiveField(6)
  final String repeatType;

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final bool isStarred;

  @HiveField(9)
  final String category;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? completedAt;

  @HiveField(12)
  final int? lunarDay;

  @HiveField(13)
  final int? lunarMonth;

  @HiveField(14)
  final int? lunarYear;

  @HiveField(15)
  final int repeatInterval;

  @HiveField(16)
  final List<int>? repeatWeekDays;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.time,
    this.isLunarCalendar = false,
    this.repeatType = 'none',
    this.isCompleted = false,
    this.isStarred = false,
    this.category = 'default',
    required this.createdAt,
    this.completedAt,
    this.lunarDay,
    this.lunarMonth,
    this.lunarYear,
    this.repeatInterval = 1,
    this.repeatWeekDays,
  });

  /// Converts from domain entity to data model.
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      time: entity.time,
      isLunarCalendar: entity.isLunarCalendar,
      repeatType: entity.repeatType.value,
      isCompleted: entity.isCompleted,
      isStarred: entity.isStarred,
      category: entity.category,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      lunarDay: entity.lunarDay,
      lunarMonth: entity.lunarMonth,
      lunarYear: entity.lunarYear,
      repeatInterval: entity.repeatInterval,
      repeatWeekDays: entity.repeatWeekDays,
    );
  }

  /// Converts to domain entity.
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      time: time,
      isLunarCalendar: isLunarCalendar,
      repeatType: RepeatType.fromString(repeatType),
      isCompleted: isCompleted,
      isStarred: isStarred,
      category: category,
      createdAt: createdAt,
      completedAt: completedAt,
      lunarDay: lunarDay,
      lunarMonth: lunarMonth,
      lunarYear: lunarYear,
      repeatInterval: repeatInterval,
      repeatWeekDays: repeatWeekDays,
    );
  }
}

/// Manual Hive TypeAdapter for TaskModel (no code generation).
class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      dueDate: fields[3] as DateTime,
      time: fields[4] as DateTime?,
      isLunarCalendar: fields[5] as bool? ?? false,
      repeatType: fields[6] as String? ?? 'none',
      isCompleted: fields[7] as bool? ?? false,
      isStarred: fields[8] as bool? ?? false,
      category: fields[9] as String? ?? 'default',
      createdAt: fields[10] as DateTime,
      completedAt: fields[11] as DateTime?,
      lunarDay: fields[12] as int?,
      lunarMonth: fields[13] as int?,
      lunarYear: fields[14] as int?,
      repeatInterval: fields[15] as int? ?? 1,
      repeatWeekDays: (fields[16] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.isLunarCalendar)
      ..writeByte(6)
      ..write(obj.repeatType)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.isStarred)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.completedAt)
      ..writeByte(12)
      ..write(obj.lunarDay)
      ..writeByte(13)
      ..write(obj.lunarMonth)
      ..writeByte(14)
      ..write(obj.lunarYear)
      ..writeByte(15)
      ..write(obj.repeatInterval)
      ..writeByte(16)
      ..write(obj.repeatWeekDays);
  }
}
