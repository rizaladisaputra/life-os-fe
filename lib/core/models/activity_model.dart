enum ActivityCategory { daily, prayer, english, learning, health, career, social, finance }

class ActivityModel {
  final String id;
  final String time;
  final String emoji;
  final String title;
  final ActivityCategory category;
  final bool isCompleted;
  final String? note;
  final String? endTime;

  const ActivityModel({
    required this.id,
    required this.time,
    required this.emoji,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.note,
    this.endTime,
  });

  ActivityModel copyWith({
    String? id,
    String? time,
    String? emoji,
    String? title,
    ActivityCategory? category,
    bool? isCompleted,
    String? note,
    String? endTime,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      time: time ?? this.time,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
      endTime: endTime ?? this.endTime,
    );
  }
}
