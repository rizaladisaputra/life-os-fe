class PrayerModel {
  final String id;
  final String name;
  final String time;
  final bool isCompleted;
  final String emoji;
  final String date;

  const PrayerModel({
    required this.id,
    required this.name,
    required this.time,
    required this.isCompleted,
    required this.emoji,
    required this.date,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    // Tentukan emoji secara dinamis berdasarkan nama sholat
    String emo = '🕌';
    final nameLower = json['name']?.toString().toLowerCase() ?? '';
    if (nameLower.contains('subuh')) {
      emo = '🌙';
    } else if (nameLower.contains('dzuhur')) {
      emo = '☀️';
    } else if (nameLower.contains('ashar')) {
      emo = '🌤️';
    } else if (nameLower.contains('maghrib')) {
      emo = '🌅';
    } else if (nameLower.contains('isya')) {
      emo = '🌙';
    }

    return PrayerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      emoji: emo,
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'name': name,
      'time': time,
      'isCompleted': isCompleted,
      'date': date,
    };
  }

  PrayerModel copyWith({
    String? id,
    String? name,
    String? time,
    bool? isCompleted,
    String? emoji,
    String? date,
  }) {
    return PrayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      emoji: emoji ?? this.emoji,
      date: date ?? this.date,
    );
  }
}
