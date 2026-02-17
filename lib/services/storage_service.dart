import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_keys.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';

class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  static const String _mealPlansKey = 'meal_plans';
  static const String _userProfileKey = 'user_profile';
  static const String _groqApiKeyKey = 'groq_api_key';
  static const String _spoonacularApiKeyKey = 'spoonacular_api_key';

  // --- API Keys ---

  Future<String?> getGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_groqApiKeyKey) ?? ApiKeys.groqApiKey;
  }

  Future<String?> getSpoonacularApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_spoonacularApiKeyKey) ?? ApiKeys.spoonacularApiKey;
  }

  // --- User Profile ---

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userProfileKey);
    if (jsonStr == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  // --- Meal Plans ---

  Future<List<MealPlan>> getSavedMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_mealPlansKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMealPlan(MealPlan plan) async {
    final plans = await getSavedMealPlans();
    plans.removeWhere((p) => p.id == plan.id);
    plans.insert(0, plan);
    await _saveMealPlans(plans);
  }

  Future<void> deleteMealPlan(String planId) async {
    final plans = await getSavedMealPlans();
    plans.removeWhere((p) => p.id == planId);
    await _saveMealPlans(plans);
  }

  Future<void> _saveMealPlans(List<MealPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(plans.map((p) => p.toJson()).toList());
    await prefs.setString(_mealPlansKey, jsonStr);
  }
}
