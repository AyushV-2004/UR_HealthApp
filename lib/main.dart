import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'features/home/screens/home_dashboard_screen.dart';
import 'firebase_options.dart';

import 'features/onboarding/splash_screen.dart';
import 'shell/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/login_screen.dart';

import 'services/ble/ble_connection_state.dart';
import 'services/ble/ble_device_provider.dart';
import 'services/ble/ble_data_provider.dart';
import 'services/ble/ble_service.dart';

import 'services/firebase/firebase_service.dart';
import 'services/sync/sync_service.dart';
import 'services/sync/sync_progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Firebase App Check (DEBUG MODE)
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
        // 🔵 BLE / Device state
        ChangeNotifierProvider(create: (_) => BleConnectionState()),
        ChangeNotifierProvider(create: (_) => BleDeviceProvider()),
        ChangeNotifierProvider(create: (_) => BleDataProvider()),

        // 🟡 Sync progress (UI state)
        ChangeNotifierProvider(create: (_) => SyncProgress()),

        // 🧠 Sync service (brain)
        Provider(
          create: (context) => SyncService(
            bleService: BleService(),
            dataProvider: context.read<BleDataProvider>(),
            firebaseService: FirebaseService(),
            syncProgress: context.read<SyncProgress>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'UrHealth',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
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
