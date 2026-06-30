import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── User Model ─────────────────────────────────────────────────────────────

class UserModel {
  final String email;
  final String displayName;

  const UserModel({required this.email, required this.displayName});

  factory UserModel.fromPrefs(SharedPreferences prefs) {
    return UserModel(
      email: prefs.getString('auth_email') ?? '',
      displayName: prefs.getString('auth_display_name') ?? '',
    );
  }

  Future<void> saveToPrefs(SharedPreferences prefs) async {
    await prefs.setString('auth_email', email);
    await prefs.setString('auth_display_name', displayName);
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

  // Simulasi "database" pengguna terdaftar (in-memory + SharedPreferences)
  static const String _accountsKey = 'registered_accounts';

  Future<void> _checkSession() async {
    state = const AuthState.loading();
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('auth_is_logged_in') ?? false;
    if (isLoggedIn) {
      final user = UserModel.fromPrefs(prefs);
      state = AuthState.authenticated(user);
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
    await Future.delayed(const Duration(milliseconds: 800)); // simulasi network

    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_accountsKey) ?? [];

    // Cek apakah email sudah terdaftar
    final emailExists = accounts.any((a) => a.startsWith('$email:'));
    if (emailExists) {
      state = const AuthState.unauthenticated();
      return 'Email sudah terdaftar. Silakan login.';
    }

    // Simpan akun baru
    accounts.add('$email:$password:$displayName');
    await prefs.setStringList(_accountsKey, accounts);

    // Login otomatis setelah signup
    final user = UserModel(email: email, displayName: displayName);
    await user.saveToPrefs(prefs);
    await prefs.setBool('auth_is_logged_in', true);

    state = AuthState.authenticated(user);
    return null; // null = sukses
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    await Future.delayed(const Duration(milliseconds: 800)); // simulasi network

    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_accountsKey) ?? [];

    // Cari akun dengan email & password yang cocok
    String? foundName;
    for (final account in accounts) {
      final parts = account.split(':');
      if (parts.length >= 3 && parts[0] == email && parts[1] == password) {
        foundName = parts[2];
        break;
      }
    }

    if (foundName == null) {
      state = const AuthState.unauthenticated();
      return 'Email atau password salah.';
    }

    final user = UserModel(email: email, displayName: foundName);
    await user.saveToPrefs(prefs);
    await prefs.setBool('auth_is_logged_in', true);

    state = AuthState.authenticated(user);
    return null; // null = sukses
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_is_logged_in', false);
    await prefs.remove('auth_email');
    await prefs.remove('auth_display_name');
    state = const AuthState.unauthenticated();
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
