import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../models/habit_model.dart';
import '../models/prayer_model.dart';

// ─── Activity Provider ─────────────────────────────────────────────────────────

final activitiesProvider = StateNotifierProvider<ActivitiesNotifier, List<ActivityModel>>((ref) {
  return ActivitiesNotifier();
});

class ActivitiesNotifier extends StateNotifier<List<ActivityModel>> {
  ActivitiesNotifier() : super(_defaultActivities());

  static List<ActivityModel> _defaultActivities() {
    return [
      ActivityModel(id: '1', time: '04:00', emoji: '🌙', title: 'Bangun', category: ActivityCategory.daily, isCompleted: true),
      ActivityModel(id: '2', time: '04:10', emoji: '🕌', title: 'Sholat Subuh', category: ActivityCategory.prayer, isCompleted: true),
      ActivityModel(id: '3', time: '04:35', emoji: '🇬🇧', title: 'Bahasa Inggris', category: ActivityCategory.english, isCompleted: false),
      ActivityModel(id: '4', time: '05:20', emoji: '📖', title: 'Membaca Buku', category: ActivityCategory.learning, isCompleted: false),
      ActivityModel(id: '5', time: '05:50', emoji: '🏃', title: 'Stretching', category: ActivityCategory.health, isCompleted: false),
      ActivityModel(id: '6', time: '06:20', emoji: '🚿', title: 'Persiapan Kerja', category: ActivityCategory.daily, isCompleted: false),
      ActivityModel(id: '7', time: '09:00', emoji: '💼', title: 'Kerja', category: ActivityCategory.career, isCompleted: false),
      ActivityModel(id: '8', time: '17:00', emoji: '🏠', title: 'Pulang', category: ActivityCategory.daily, isCompleted: false),
      ActivityModel(id: '9', time: '18:30', emoji: '🏋', title: 'Gym', category: ActivityCategory.health, isCompleted: false),
    ];
  }

  void toggleComplete(String id) {
    state = state.map((a) {
      if (a.id == id) return a.copyWith(isCompleted: !a.isCompleted);
      return a;
    }).toList();
  }

  void deleteActivity(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  double get completionRate {
    if (state.isEmpty) return 0;
    return state.where((a) => a.isCompleted).length / state.length;
  }
}

// ─── Habit Provider ─────────────────────────────────────────────────────────

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<HabitModel>>((ref) {
  return HabitsNotifier();
});

class HabitsNotifier extends StateNotifier<List<HabitModel>> {
  HabitsNotifier() : super(_defaultHabits());

  static List<HabitModel> _defaultHabits() {
    return [
      HabitModel(id: '1', name: 'Sholat 5 Waktu', emoji: '🕌', completedDays: _generateDays(27)),
      HabitModel(id: '2', name: 'Subuh Tepat Waktu', emoji: '🌅', completedDays: _generateDays(22)),
      HabitModel(id: '3', name: 'Bahasa Inggris', emoji: '🇬🇧', completedDays: _generateDays(18)),
      HabitModel(id: '4', name: 'Membaca Buku', emoji: '📖', completedDays: _generateDays(15)),
      HabitModel(id: '5', name: 'Workout', emoji: '💪', completedDays: _generateDays(12)),
      HabitModel(id: '6', name: 'Minum Air 2L', emoji: '💧', completedDays: _generateDays(24)),
      HabitModel(id: '7', name: 'Tidur Sebelum 22.00', emoji: '🌙', completedDays: _generateDays(20)),
      HabitModel(id: '8', name: 'No Doom Scrolling', emoji: '📵', completedDays: _generateDays(10)),
    ];
  }

  static List<DateTime> _generateDays(int count) {
    final now = DateTime.now();
    final days = <DateTime>[];
    for (int i = count; i >= 0; i--) {
      if (days.length >= count) break;
      final day = now.subtract(Duration(days: i));
      if (i % 3 != 0 || i == 0) days.add(day);
    }
    return days;
  }

  void toggleToday(String id) {
    state = state.map((h) {
      if (h.id == id) {
        final today = DateTime.now();
        final hasToday = h.completedDays.any((d) =>
            d.year == today.year && d.month == today.month && d.day == today.day);
        if (hasToday) {
          return h.copyWith(
            completedDays: h.completedDays.where((d) =>
              !(d.year == today.year && d.month == today.month && d.day == today.day)
            ).toList(),
          );
        } else {
          return h.copyWith(completedDays: [...h.completedDays, today]);
        }
      }
      return h;
    }).toList();
  }
}

// ─── Prayer Provider ─────────────────────────────────────────────────────────

final prayerProvider = StateNotifierProvider<PrayerNotifier, List<PrayerModel>>((ref) {
  return PrayerNotifier();
});

class PrayerNotifier extends StateNotifier<List<PrayerModel>> {
  PrayerNotifier() : super(_defaultPrayers());

  static List<PrayerModel> _defaultPrayers() {
    return [
      PrayerModel(name: 'Subuh', time: '04:10', isCompleted: true, emoji: '🌙'),
      PrayerModel(name: 'Dzuhur', time: '12:05', isCompleted: true, emoji: '☀️'),
      PrayerModel(name: 'Ashar', time: '15:20', isCompleted: false, emoji: '🌤️'),
      PrayerModel(name: 'Maghrib', time: '17:58', isCompleted: false, emoji: '🌅'),
      PrayerModel(name: 'Isya', time: '19:10', isCompleted: false, emoji: '🌙'),
    ];
  }

  void toggleCompleted(String name) {
    state = state.map((p) {
      if (p.name == name) return p.copyWith(isCompleted: !p.isCompleted);
      return p;
    }).toList();
  }

  double get completionRate {
    if (state.isEmpty) return 0;
    return state.where((p) => p.isCompleted).length / state.length;
  }
}

// ─── Today's Progress ─────────────────────────────────────────────────────────

final todayProgressProvider = Provider<double>((ref) {
  final activities = ref.watch(activitiesProvider);
  final prayers = ref.watch(prayerProvider);
  final habits = ref.watch(habitsProvider);

  final activityScore = activities.isEmpty
      ? 0.0
      : activities.where((a) => a.isCompleted).length / activities.length;

  final prayerScore = prayers.isEmpty
      ? 0.0
      : prayers.where((p) => p.isCompleted).length / prayers.length;

  final habitScore = habits.isEmpty
      ? 0.0
      : habits.where((h) {
          final today = DateTime.now();
          return h.completedDays.any((d) =>
              d.year == today.year && d.month == today.month && d.day == today.day);
        }).length / habits.length;

  return (activityScore * 0.4 + prayerScore * 0.4 + habitScore * 0.2).clamp(0, 1);
});

// ─── Weekly Goals Provider ─────────────────────────────────────────────────────

final weeklyGoalsProvider = StateProvider<List<WeeklyGoalModel>>((ref) {
  return [
    WeeklyGoalModel(title: 'Bahasa Inggris', emoji: '🇬🇧', current: 8, target: 10, unit: 'jam'),
    WeeklyGoalModel(title: 'Workout', emoji: '🏋', current: 3, target: 4, unit: 'kali'),
    WeeklyGoalModel(title: 'Buku', emoji: '📖', current: 2, target: 5, unit: 'jam'),
    WeeklyGoalModel(title: 'Belajar Skill', emoji: '💻', current: 5, target: 8, unit: 'jam'),
    WeeklyGoalModel(title: 'Investasi', emoji: '💰', current: 1, target: 2, unit: 'jam'),
  ];
});

class WeeklyGoalModel {
  final String title;
  final String emoji;
  final int current;
  final int target;
  final String unit;

  WeeklyGoalModel({
    required this.title,
    required this.emoji,
    required this.current,
    required this.target,
    required this.unit,
  });

  double get progress => (current / target).clamp(0, 1);
}
