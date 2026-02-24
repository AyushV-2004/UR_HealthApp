import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';

// Screens
import 'features/home/screens/home_dashboard_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'shell/app_shell.dart';

// Theme
import 'core/theme/app_theme.dart';

// BLE
import 'services/ble/ble_connection_state.dart';
import 'services/ble/ble_device_provider.dart';
import 'services/ble/ble_data_provider.dart';
import 'services/ble/ble_service.dart';

// Firebase
import 'services/firebase/firebase_service.dart';

// Sync
import 'services/sync/sync_service.dart';
import 'services/sync/sync_progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔐 App Check (Debug mode)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  runApp(const UrHealthApp());
}

class UrHealthApp extends StatelessWidget {
  const UrHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        // ==========================================================
        // 🔵 CORE BLE LAYER
        // ==========================================================

        // ✅ SINGLE BleService instance (VERY IMPORTANT)
        Provider<BleService>(
          create: (_) => BleService(),
        ),

        // ✅ Global connection state
        ChangeNotifierProvider<BleConnectionState>(
          create: (_) => BleConnectionState(),
        ),

        // ✅ Device provider depends on SAME BleService + SAME ConnectionState
        ChangeNotifierProxyProvider2<
            BleService,
            BleConnectionState,
            BleDeviceProvider>(
          create: (context) => BleDeviceProvider(
            bleService: context.read<BleService>(),
            connectionState: context.read<BleConnectionState>(),
          ),
          update: (context, bleService, connectionState, previous) =>
          previous ??
              BleDeviceProvider(
                bleService: bleService,
                connectionState: connectionState,
              ),
        ),

        // ✅ BLE data buffer
        ChangeNotifierProvider<BleDataProvider>(
          create: (_) => BleDataProvider(),
        ),

        // ==========================================================
        // 🟡 SYNC LAYER
        // ==========================================================

        ChangeNotifierProvider<SyncProgress>(
          create: (_) => SyncProgress(),
        ),

        ProxyProvider3<
            BleService,
            BleDataProvider,
            SyncProgress,
            SyncService>(
          update: (_, bleService, dataProvider, syncProgress, __) =>
              SyncService(
                bleService: bleService,
                dataProvider: dataProvider,
                firebaseService: FirebaseService(),
                syncProgress: syncProgress,
              ),
        ),
      ],

      child: MaterialApp(
        title: 'UrHealth',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Initial screen
        home: const SplashScreen(),

        // App routes
        routes: {
          '/app': (context) => const AppShell(),
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeDashboardScreen(),
        },
      ),
    );
  }
}