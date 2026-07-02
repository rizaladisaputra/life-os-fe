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
  final String date; // format: YYYY-MM-DD

  const ActivityModel({
    required this.id,
    required this.time,
    required this.emoji,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.note,
    this.endTime,
    required this.date,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    // Parsing enum secara aman
    ActivityCategory cat = ActivityCategory.daily;
    final catStr = json['category']?.toString().toLowerCase();
    for (var value in ActivityCategory.values) {
      if (value.name.toLowerCase() == catStr) {
        cat = value;
        break;
      }
    }

    return ActivityModel(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      emoji: json['emoji'] ?? '📝',
      title: json['title'] ?? '',
      category: cat,
      isCompleted: json['isCompleted'] ?? false,
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'time': time,
      'emoji': emoji,
      'title': title,
      'category': category.name.toUpperCase(),
      'isCompleted': isCompleted,
      'date': date,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? time,
    String? emoji,
    String? title,
    ActivityCategory? category,
    bool? isCompleted,
    String? note,
    String? endTime,
    String? date,
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
      date: date ?? this.date,
    );
  }
}
