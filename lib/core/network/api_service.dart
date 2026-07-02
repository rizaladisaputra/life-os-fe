import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'http_notification_interceptor.dart';

class ApiService {
  late final Dio dio;

  // Deteksi platform dinamis untuk URL backend
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    // Android emulator menggunakan 10.0.2.2 untuk mengakses host loopback
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Tambahkan Interceptors untuk logging dan otentikasi otomatis
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('jwt_token');

          // Jika ada JWT token tersimpan, sisipkan otomatis ke Authorization Header
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('🌐 API Request: [${options.method}] ${options.uri}');
            if (options.data != null) {
              print('   Payload: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ API Response: [${response.statusCode}] ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('❌ API Error: [${e.response?.statusCode}] ${e.requestOptions.path}');
            print('   Message: ${e.message}');
            print('   Response: ${e.response?.data}');
          }

          // Otomatis tangani jika token kedaluwarsa atau tidak sah (401 / 403)
          if (e.response?.statusCode == 401) {
            _clearSession();
          }

          return handler.next(e);
        },
      ),
    );

    // Chucker - HTTP inspector visual (hanya saat debug mode)
    if (kDebugMode) {
      dio.interceptors.add(ChuckerDioInterceptor());
      // System notification di Android notification shade
      dio.interceptors.add(HttpNotificationInterceptor());
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_is_logged_in', false);
    await prefs.remove('jwt_token');
    await prefs.remove('auth_email');
    await prefs.remove('auth_display_name');
  }
}

// Instance global single-ton untuk digunakan di seluruh provider
final apiService = ApiService();
