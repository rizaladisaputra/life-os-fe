class HabitModel {
  final String id;
  final String name;
  final String emoji;
  final List<DateTime> completedDays;
  final bool isActiveToday;

  const HabitModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.completedDays,
    this.isActiveToday = true,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    String? emoji,
    List<DateTime>? completedDays,
    bool? isActiveToday,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      completedDays: completedDays ?? this.completedDays,
      isActiveToday: isActiveToday ?? this.isActiveToday,
    );
  }

  bool get completedToday {
    final today = DateTime.now();
    return completedDays.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  }

  int get currentStreak {
    if (completedDays.isEmpty) return 0;
    final sorted = [...completedDays]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime expected = DateTime.now();
    for (final day in sorted) {
      if (day.year == expected.year &&
          day.month == expected.month &&
          day.day == expected.day) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}

