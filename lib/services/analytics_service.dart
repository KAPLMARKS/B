import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'logger_service.dart';

/// Unified analytics facade that dispatches events to all providers:
/// Firebase Analytics, AppMetrica, and AppsFlyer.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;

  final FirebaseAnalytics _firebase = FirebaseAnalytics.instance;
  AppsflyerSdk? _appsFlyer;

  /// Must be called after AppsFlyer SDK is initialized.
  void setAppsFlyerInstance(AppsflyerSdk sdk) {
    _appsFlyer = sdk;
  }

  /// User generated a meal plan.
  Future<void> logGeneratePlan({
    required String goal,
    required int mealsPerDay,
  }) async {
    const event = 'generate_meal_plan';
    final params = {'goal': goal, 'meals_per_day': mealsPerDay.toString()};

    await _firebaseLog(event, {'goal': goal, 'meals_per_day': mealsPerDay});
    _appMetricaLog(event, params);
    _appsFlyerLog(event, params);

    AppLogger.info('Event: $event (goal=$goal, meals=$mealsPerDay)', source: 'Analytics');
  }

  /// User saved a meal plan.
  Future<void> logSavePlan({required String planName}) async {
    const event = 'save_meal_plan';
    final params = {'plan_name': planName};

    await _firebaseLog(event, params);
    _appMetricaLog(event, params);
    _appsFlyerLog(event, params);

    AppLogger.info('Event: $event (plan=$planName)', source: 'Analytics');
  }

  /// User searched for a recipe.
  Future<void> logFindRecipe({required String mealName}) async {
    const event = 'find_recipe';
    final params = {'meal_name': mealName};

    await _firebaseLog(event, params);
    _appMetricaLog(event, params);
    _appsFlyerLog(event, params);

    AppLogger.info('Event: $event (meal=$mealName)', source: 'Analytics');
  }

  /// User opened a recipe detail screen.
  Future<void> logViewRecipe({required String recipeTitle}) async {
    const event = 'view_recipe';
    final params = {'recipe_title': recipeTitle};

    await _firebaseLog(event, params);
    _appMetricaLog(event, params);
    _appsFlyerLog(event, params);
  }

  /// User deleted a saved plan.
  Future<void> logDeletePlan({required String planName}) async {
    const event = 'delete_meal_plan';
    final params = {'plan_name': planName};

    await _firebaseLog(event, params);
    _appMetricaLog(event, params);
    _appsFlyerLog(event, params);
  }

  // --- Private helpers ---

  Future<void> _firebaseLog(String event, Map<String, Object> params) async {
    try {
      await _firebase.logEvent(name: event, parameters: params);
    } catch (e) {
      AppLogger.error('Firebase Analytics error: $e', source: 'Analytics');
    }
  }

  void _appMetricaLog(String event, Map<String, Object> params) {
    try {
      AppMetrica.reportEventWithMap(event, params.map((k, v) => MapEntry(k, v.toString())));
    } catch (e) {
      AppLogger.error('AppMetrica error: $e', source: 'Analytics');
    }
  }

  void _appsFlyerLog(String event, Map<String, dynamic> params) {
    try {
      _appsFlyer?.logEvent(event, params);
    } catch (e) {
      AppLogger.error('AppsFlyer error: $e', source: 'Analytics');
    }
  }
}
