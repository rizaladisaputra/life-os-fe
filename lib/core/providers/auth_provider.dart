import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../network/api_service.dart';

// ─── User Model ─────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final int xp;
  final int level;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.xp,
    required this.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
    );
  }

  factory UserModel.fromPrefs(SharedPreferences prefs) {
    return UserModel(
      id: prefs.getString('auth_user_id') ?? '',
      email: prefs.getString('auth_email') ?? '',
      displayName: prefs.getString('auth_display_name') ?? '',
      xp: prefs.getInt('auth_xp') ?? 0,
      level: prefs.getInt('auth_level') ?? 1,
    );
  }

  Future<void> saveToPrefs(SharedPreferences prefs) async {
    await prefs.setString('auth_user_id', id);
    await prefs.setString('auth_email', email);
    await prefs.setString('auth_display_name', displayName);
    await prefs.setInt('auth_xp', xp);
    await prefs.setInt('auth_level', level);
  }
}

// ─── Auth State ──────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(UserModel user)
      : status = AuthStatus.authenticated,
        user = user,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

// ─── Auth Notifier ───────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    state = const AuthState.loading();
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('auth_is_logged_in') ?? false;
    final token = prefs.getString('jwt_token') ?? '';

    if (isLoggedIn && token.isNotEmpty) {
      // Ambil profile dari backend untuk menjamin data paling valid & sync
      try {
        final response = await apiService.dio.get('/api/users/me');
        final user = UserModel.fromJson(response.data);
        await user.saveToPrefs(prefs);
        state = AuthState.authenticated(user);
      } catch (e) {
        // Jika gagal koneksi/session expired, gunakan cache lokal atau logout
        final user = UserModel.fromPrefs(prefs);
        if (user.email.isNotEmpty) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      }
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<String?> signup({
    required String email,
    required String displayName,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await apiService.dio.post(
        '/api/auth/signup',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );

      final token = response.data['token'];
      final user = UserModel.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await user.saveToPrefs(prefs);
      await prefs.setBool('auth_is_logged_in', true);

      state = AuthState.authenticated(user);
      return null; // Sukses
    } on DioException catch (e) {
      state = const AuthState.unauthenticated();
      if (e.response != null && e.response!.data != null) {
        // Coba baca error RFC 9457 dari backend
        final detail = e.response!.data['detail'];
        return detail ?? 'Registrasi gagal. Silakan coba lagi.';
      }
      return 'Koneksi ke server gagal.';
    } catch (e) {
      state = const AuthState.unauthenticated();
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await apiService.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      final user = UserModel.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await user.saveToPrefs(prefs);
      await prefs.setBool('auth_is_logged_in', true);

      state = AuthState.authenticated(user);
      return null; // Sukses
    } on DioException catch (e) {
      state = const AuthState.unauthenticated();
      if (e.response != null && e.response!.data != null) {
        // Coba baca error RFC 9457 dari backend
        final detail = e.response!.data['detail'];
        return detail ?? 'Email atau password salah.';
      }
      return 'Koneksi ke server gagal.';
    } catch (e) {
      state = const AuthState.unauthenticated();
      return e.toString();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_is_logged_in', false);
    await prefs.remove('jwt_token');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_email');
    await prefs.remove('auth_display_name');
    await prefs.remove('auth_xp');
    await prefs.remove('auth_level');
    state = const AuthState.unauthenticated();
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
