/// Enum representing repeat types for tasks.
enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  String get value {
    switch (this) {
      case RepeatType.none:
        return 'none';
      case RepeatType.daily:
        return 'daily';
      case RepeatType.weekly:
        return 'weekly';
      case RepeatType.monthly:
        return 'monthly';
      case RepeatType.yearly:
        return 'yearly';
    }
  }

  static RepeatType fromString(String value) {
    switch (value) {
      case 'daily':
        return RepeatType.daily;
      case 'weekly':
        return RepeatType.weekly;
      case 'monthly':
        return RepeatType.monthly;
      case 'yearly':
        return RepeatType.yearly;
      default:
        return RepeatType.none;
    }
  }
}

/// Domain entity representing a task.
class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final DateTime? time;
  final bool isLunarCalendar;
  final RepeatType repeatType;
  final int repeatInterval;
  final bool isCompleted;
  final bool isStarred;
  final String category;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? lunarDay;
  final int? lunarMonth;
  final int? lunarYear;
  final List<int>? repeatWeekDays;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.time,
    this.isLunarCalendar = false,
    this.repeatType = RepeatType.none,
    this.repeatInterval = 1,
    this.isCompleted = false,
    this.isStarred = false,
    this.category = 'default',
    required this.createdAt,
    this.completedAt,
    this.lunarDay,
    this.lunarMonth,
    this.lunarYear,
    this.repeatWeekDays,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? time,
    bool? isLunarCalendar,
    RepeatType? repeatType,
    int? repeatInterval,
    bool? isCompleted,
    bool? isStarred,
    String? category,
    DateTime? createdAt,
    DateTime? completedAt,
    int? lunarDay,
    int? lunarMonth,
    int? lunarYear,
    List<int>? repeatWeekDays,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      time: time ?? this.time,
      isLunarCalendar: isLunarCalendar ?? this.isLunarCalendar,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarred: isStarred ?? this.isStarred,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      lunarDay: lunarDay ?? this.lunarDay,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      lunarYear: lunarYear ?? this.lunarYear,
      repeatWeekDays: repeatWeekDays ?? this.repeatWeekDays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
