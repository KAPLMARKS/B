import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/sdk_keys.dart';
import 'services/analytics_service.dart';
import 'services/logger_service.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();
  AppLogger.info('Firebase initialized', source: 'Init');

  // AppMetrica
  await AppMetrica.activate(
    AppMetricaConfig(SdkKeys.appMetricaApiKey),
  );
  AppLogger.info('AppMetrica initialized', source: 'Init');

  // AppsFlyer
  final appsFlyerOptions = AppsFlyerOptions(
    afDevKey: SdkKeys.appsFlyerDevKey,
    showDebug: true,
  );
  final appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);
  await appsFlyerSdk.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
    registerOnDeepLinkingCallback: true,
  );
  AnalyticsService().setAppsFlyerInstance(appsFlyerSdk);
  AppLogger.info('AppsFlyer initialized', source: 'Init');

  // AdMob
  await MobileAds.instance.initialize();
  AppLogger.info('AdMob initialized', source: 'Init');

  runApp(const MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _historyKey = GlobalKey<HistoryScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    HistoryScreen(key: _historyKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            _historyKey.currentState?.loadPlans();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
