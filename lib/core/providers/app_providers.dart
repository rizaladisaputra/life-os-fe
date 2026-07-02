import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/activity_model.dart';
import '../models/habit_model.dart';
import '../models/prayer_model.dart';
import '../network/api_service.dart';

// ─── Activity Provider ─────────────────────────────────────────────────────────

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<ActivityModel>>((ref) {
  final notifier = ActivitiesNotifier();
  // Load data untuk hari ini secara otomatis saat diinisialisasi
  notifier.loadActivities(DateTime.now());
  return notifier;
});

class ActivitiesNotifier extends StateNotifier<List<ActivityModel>> {
  ActivitiesNotifier() : super([]);

  Future<void> loadActivities(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final response = await apiService.dio.get('/api/activities', queryParameters: {'date': dateStr});
      final List<dynamic> data = response.data;
      state = data.map((json) => ActivityModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading activities: $e");
    }
  }

  Future<String?> createActivity(ActivityModel activity) async {
    try {
      final response = await apiService.dio.post(
        '/api/activities',
        data: activity.toJson(),
      );
      final newActivity = ActivityModel.fromJson(response.data);
      state = [...state, newActivity];
      return null; // Sukses
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['detail'] ?? 'Gagal membuat aktivitas.';
      }
      return 'Gagal tersambung ke server.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> toggleComplete(String id) async {
    // Optimistic UI update
    final oldState = state;
    state = state.map((a) {
      if (a.id == id) return a.copyWith(isCompleted: !a.isCompleted);
      return a;
    }).toList();

    try {
      final response = await apiService.dio.put('/api/activities/$id/toggle');
      final updated = ActivityModel.fromJson(response.data);
      state = oldState.map((a) => a.id == id ? updated : a).toList();
    } catch (e) {
      // Revert jika gagal
      state = oldState;
      print("Error toggling activity: $e");
    }
  }

  Future<void> deleteActivity(String id) async {
    final oldState = state;
    state = state.where((a) => a.id != id).toList();

    try {
      await apiService.dio.delete('/api/activities/$id');
    } catch (e) {
      // Revert jika gagal
      state = oldState;
      print("Error deleting activity: $e");
    }
  }

  double get completionRate {
    if (state.isEmpty) return 0;
    return state.where((a) => a.isCompleted).length / state.length;
  }
}

// ─── Habit Provider ─────────────────────────────────────────────────────────

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<HabitModel>>((ref) {
  final notifier = HabitsNotifier();
  notifier.loadHabits();
  return notifier;
});

class HabitsNotifier extends StateNotifier<List<HabitModel>> {
  HabitsNotifier() : super([]);

  Future<void> loadHabits() async {
    try {
      final response = await apiService.dio.get('/api/habits');
      final List<dynamic> data = response.data;
      state = data.map((json) => HabitModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading habits: $e");
    }
  }

  Future<String?> createHabit(String name, String emoji) async {
    try {
      final response = await apiService.dio.post(
        '/api/habits',
        data: {
          'name': name,
          'emoji': emoji,
        },
      );
      final newHabit = HabitModel.fromJson(response.data);
      state = [...state, newHabit];
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['detail'] ?? 'Gagal membuat kebiasaan.';
      }
      return 'Gagal tersambung ke server.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> toggleToday(String id) async {
    final oldState = state;
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Optimistic UI update
    state = state.map((h) {
      if (h.id == id) {
        final hasToday = h.completedDays.any((d) =>
            d.year == today.year && d.month == today.month && d.day == today.day);
        if (hasToday) {
          return h.copyWith(
            completedDays: h.completedDays
                .where((d) => !(d.year == today.year && d.month == today.month && d.day == today.day))
                .toList(),
          );
        } else {
          return h.copyWith(completedDays: [...h.completedDays, today]);
        }
      }
      return h;
    }).toList();

    try {
      final response = await apiService.dio.put('/api/habits/$id/toggle', queryParameters: {'date': dateStr});
      final updated = HabitModel.fromJson(response.data);
      state = oldState.map((h) => h.id == id ? updated : h).toList();
    } catch (e) {
      state = oldState;
      print("Error toggling habit: $e");
    }
  }

  Future<void> deleteHabit(String id) async {
    final oldState = state;
    state = state.where((h) => h.id != id).toList();

    try {
      await apiService.dio.delete('/api/habits/$id');
    } catch (e) {
      state = oldState;
      print("Error deleting habit: $e");
    }
  }
}

// ─── Prayer Provider ─────────────────────────────────────────────────────────

final prayerProvider =
    StateNotifierProvider<PrayerNotifier, List<PrayerModel>>((ref) {
  final notifier = PrayerNotifier();
  notifier.loadPrayers(DateTime.now());
  return notifier;
});

class PrayerNotifier extends StateNotifier<List<PrayerModel>> {
  PrayerNotifier() : super([]);

  Future<void> loadPrayers(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final response = await apiService.dio.get('/api/prayers', queryParameters: {'date': dateStr});
      final List<dynamic> data = response.data;
      state = data.map((json) => PrayerModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading prayers: $e");
    }
  }

  Future<void> toggleCompleted(String id) async {
    final oldState = state;
    state = state.map((p) {
      if (p.id == id) return p.copyWith(isCompleted: !p.isCompleted);
      return p;
    }).toList();

    try {
      final response = await apiService.dio.put('/api/prayers/$id/toggle');
      final updated = PrayerModel.fromJson(response.data);
      state = oldState.map((p) => p.id == id ? updated : p).toList();
    } catch (e) {
      state = oldState;
      print("Error toggling prayer: $e");
    }
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
                d.year == today.year &&
                d.month == today.month &&
                d.day == today.day);
          }).length /
          habits.length;

  return (activityScore * 0.4 + prayerScore * 0.4 + habitScore * 0.2)
      .clamp(0, 1);
});

// ─── Weekly Goals Provider ─────────────────────────────────────────────────────

final weeklyGoalsProvider =
    StateNotifierProvider<WeeklyGoalsNotifier, List<WeeklyGoalModel>>((ref) {
  final notifier = WeeklyGoalsNotifier();
  notifier.loadGoals();
  return notifier;
});

class WeeklyGoalsNotifier extends StateNotifier<List<WeeklyGoalModel>> {
  WeeklyGoalsNotifier() : super([]);

  Future<void> loadGoals() async {
    try {
      final response = await apiService.dio.get('/api/weekly-goals');
      final List<dynamic> data = response.data;
      state = data.map((json) => WeeklyGoalModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading weekly goals: $e");
    }
  }

  Future<String?> createGoal(String title, String emoji, int target, String unit) async {
    try {
      final response = await apiService.dio.post(
        '/api/weekly-goals',
        data: {
          'title': title,
          'emoji': emoji,
          'target': target,
          'unit': unit,
        },
      );
      final newGoal = WeeklyGoalModel.fromJson(response.data);
      state = [...state, newGoal];
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['detail'] ?? 'Gagal membuat target mingguan.';
      }
      return 'Gagal tersambung ke server.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> incrementGoal(String id, {int amount = 1}) async {
    final oldState = state;
    state = state.map((g) {
      if (g.id == id) {
        final newCurrent = (g.current + amount).clamp(0, g.target);
        return g.copyWith(current: newCurrent);
      }
      return g;
    }).toList();

    try {
      final response = await apiService.dio.put(
        '/api/weekly-goals/$id/increment',
        queryParameters: {'amount': amount},
      );
      final updated = WeeklyGoalModel.fromJson(response.data);
      state = oldState.map((g) => g.id == id ? updated : g).toList();
    } catch (e) {
      state = oldState;
      print("Error incrementing goal: $e");
    }
  }

  Future<void> deleteGoal(String id) async {
    final oldState = state;
    state = state.where((g) => g.id != id).toList();

    try {
      await apiService.dio.delete('/api/weekly-goals/$id');
    } catch (e) {
      state = oldState;
      print("Error deleting goal: $e");
    }
  }
}

class WeeklyGoalModel {
  final String id;
  final String title;
  final String emoji;
  final int current;
  final int target;
  final String unit;

  WeeklyGoalModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.current,
    required this.target,
    required this.unit,
  });

  factory WeeklyGoalModel.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      emoji: json['emoji'] ?? '🎯',
      current: json['current'] ?? 0,
      target: json['target'] ?? 1,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'title': title,
      'emoji': emoji,
      'current': current,
      'target': target,
      'unit': unit,
    };
  }

  WeeklyGoalModel copyWith({
    String? id,
    String? title,
    String? emoji,
    int? current,
    int? target,
    String? unit,
  }) {
    return WeeklyGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      current: current ?? this.current,
      target: target ?? this.target,
      unit: unit ?? this.unit,
    );
  }

  double get progress => (current / target).clamp(0, 1);
}
