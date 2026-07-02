import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Custom Dio interceptor yang menampilkan system notification
/// di Android notification shade setiap kali ada HTTP request/response.
/// Mirip dengan tampilan "Recording HTTP activity" seperti di Chucker Android native.
class HttpNotificationInterceptor extends Interceptor {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Inisialisasi flutter_local_notifications — panggil sekali dari main()
  static Future<void> initialize() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(initSettings);

    // Minta izin notifikasi (Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static const _channelId = 'http_inspector';
  static const _channelName = 'HTTP Inspector';
  static const _channelDesc = 'Menampilkan aktivitas HTTP request dari LifeOS';

  // Gunakan satu ID notifikasi yang sama agar semua request terakumulasi
  // dalam satu notifikasi (seperti behavior Chucker Android)
  static const _notificationId = 9901;

  final List<String> _recentRequests = [];
  int _requestCount = 0;

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      _showNotification(
        method: response.requestOptions.method,
        statusCode: response.statusCode ?? 0,
        path: response.requestOptions.path,
      );
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      _showNotification(
        method: err.requestOptions.method,
        statusCode: err.response?.statusCode ?? -1,
        path: err.requestOptions.path,
      );
    }
    handler.next(err);
  }

  Future<void> _showNotification({
    required String method,
    required int statusCode,
    required String path,
  }) async {
    if (!_initialized) return;

    _requestCount++;
    final entry = '$statusCode $method $path';
    _recentRequests.add(entry);
    // Simpan hanya 10 request terbaru
    if (_recentRequests.length > 10) {
      _recentRequests.removeAt(0);
    }

    final styleLines = _recentRequests.reversed.toList();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      styleInformation: InboxStyleInformation(
        styleLines,
        contentTitle: 'Recording HTTP activity',
        summaryText: '$_requestCount requests',
      ),
      icon: '@mipmap/ic_launcher',
    );

    try {
      await _notificationsPlugin.show(
        _notificationId,
        'LifeOS HTTP Inspector',
        '$_requestCount HTTP requests recorded',
        NotificationDetails(android: androidDetails),
      );
      log('HttpNotificationInterceptor: $method $path - $statusCode');
    } catch (e) {
      log('HttpNotificationInterceptor error: $e');
    }
  }
}
