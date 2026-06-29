class PrayerModel {
  final String name;
  final String time;
  final bool isCompleted;
  final String emoji;

  const PrayerModel({
    required this.name,
    required this.time,
    required this.isCompleted,
    required this.emoji,
  });

  PrayerModel copyWith({
    String? name,
    String? time,
    bool? isCompleted,
    String? emoji,
  }) {
    return PrayerModel(
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      emoji: emoji ?? this.emoji,
    );
  }
}
