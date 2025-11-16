import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/auth/firebase_service.dart';
import 'core/offline/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/router/app_routes.dart';
import 'l10n/localization_service.dart';
import 'l10n/language_provider.dart';
import 'data/data_sources/local/auth_local_ds.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initializeServices();

  // Get SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MilkMintApp(),
    ),
  );
}

/// Initialize all required services
Future<void> _initializeServices() async {
  try {
    // Initialize Hive for offline storage
    await HiveService.initialize();

    // Initialize Firebase
    await FirebaseService.initialize();

    // Initialize auth local data source
    final authLocalDs = AuthLocalDataSource();
    await authLocalDs.init();
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }
}

class MilkMintApp extends ConsumerStatefulWidget {
  const MilkMintApp({super.key});

  @override
  ConsumerState<MilkMintApp> createState() => _MilkMintAppState();
}

class _MilkMintAppState extends ConsumerState<MilkMintApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize(navigatorKey: _navigatorKey);
    
    // Handle pending navigation after initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      notificationService.handlePendingNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(languageProvider);
    final languageCode = currentLocale.languageCode;
    final themeMode = ref.watch(themeModeProvider);

    // Listen to notification navigation events
    ref.listen<AsyncValue<NotificationPayload>>(
      notificationNavigationProvider,
      (previous, next) {
        next.whenData((payload) {
          // Navigation is handled by NotificationService
          debugPrint('Navigation event received: ${payload.type}');
        });
      },
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'MilkMint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('kn'),
      ],
      localizationsDelegates: [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}


