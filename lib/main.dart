import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/http_notification_interceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-warm SharedPreferences agar auth state tersedia saat startup
  await SharedPreferences.getInstance();

  // Konfigurasi Chucker: aktifkan notifikasi overlay otomatis di debug mode
  if (kDebugMode) {
    ChuckerFlutter.configure(
      showNotification: true,
      notificationAlignment: Alignment.bottomLeft,
    );
    // Inisialisasi system notification channel untuk HTTP activity
    await HttpNotificationInterceptor.initialize();
  }
  runApp(
    const ProviderScope(
      child: LifeOSApp(),
    ),
  );
}

class LifeOSApp extends ConsumerWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Chucker WAJIB mendapat navigatorKey di level MaterialApp
      // agar overlay notifikasi bisa ditampilkan di atas semua widget
      navigatorKey: ChuckerFlutter.navigatorKey,
      // GoRouter.routerDelegate menggantikan MaterialApp.router
      home: Router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}
