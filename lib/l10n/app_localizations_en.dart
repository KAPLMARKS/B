// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Meal Planner';

  @override
  String get navPlanner => 'Planner';

  @override
  String get navHistory => 'History';

  @override
  String get goalSectionTitle => 'Goal';

  @override
  String get goalWeightLoss => 'Weight Loss';

  @override
  String get goalMuscle => 'Muscle';

  @override
  String get goalMuscleGain => 'Muscle Gain';

  @override
  String get goalHealth => 'Health';

  @override
  String get genderSectionTitle => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get ageLabel => 'Age';

  @override
  String get ageSuffix => 'yrs';

  @override
  String get weightLabel => 'Weight';

  @override
  String get weightSuffix => 'kg';

  @override
  String get heightLabel => 'Height';

  @override
  String get heightSuffix => 'cm';

  @override
  String get invalidField => 'Invalid';

  @override
  String get activityLevelTitle => 'Activity Level';

  @override
  String get activitySedentary => 'Sedentary (little/no exercise)';

  @override
  String get activityLight => 'Light activity (1-3 days/week)';

  @override
  String get activityModerate => 'Moderate (3-5 days/week)';

  @override
  String get activityActive => 'Active (6-7 days/week)';

  @override
  String get activityVeryActive => 'Very active (daily)';

  @override
  String get dietaryRestrictionsTitle => 'Dietary Restrictions';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietGlutenFree => 'Gluten-Free';

  @override
  String get dietLactoseFree => 'Lactose-Free';

  @override
  String get dietKeto => 'Keto';

  @override
  String get dietHalal => 'Halal';

  @override
  String get allergiesLabel => 'Allergies';

  @override
  String get allergiesHint => 'nuts, seafood...';

  @override
  String mealsPerDay(int count) {
    return 'Meals per day: $count';
  }

  @override
  String get generateMealPlan => 'Generate Meal Plan';

  @override
  String errorGeneric(String message) {
    return 'Error: $message';
  }

  @override
  String get generating => 'Generating...';

  @override
  String get regeneratingPlan => 'Regenerating plan...';

  @override
  String get planSaved => 'Plan saved';

  @override
  String get noRecipesFound => 'No recipes found';

  @override
  String get chooseRecipe => 'Choose a recipe';

  @override
  String get cancel => 'Cancel';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String failedToLoadRecipe(String error) {
    return 'Failed to load recipe: $error';
  }

  @override
  String goalWithValue(String goal) {
    return 'Goal: $goal';
  }

  @override
  String get savePlanTooltip => 'Save plan';

  @override
  String get regenerateTooltip => 'Regenerate';

  @override
  String get newPlan => 'New Plan';

  @override
  String get saved => 'Saved';

  @override
  String get save => 'Save';

  @override
  String get savedPlans => 'Saved Plans';

  @override
  String get noSavedPlansYet => 'No saved plans yet';

  @override
  String get createPlanHint => 'Create a plan on the main screen';

  @override
  String get deletePlanTitle => 'Delete plan?';

  @override
  String deletePlanConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String mealsCount(int count) {
    return '$count meals';
  }

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String servingsCount(int count) {
    return '$count servings';
  }

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get mealSecondBreakfast => 'Second Breakfast';

  @override
  String get kcalUnit => 'kcal';

  @override
  String get gramUnit => 'g';

  @override
  String get findRecipe => 'Find Recipe';

  @override
  String get nutrientProteinShort => 'P';

  @override
  String get nutrientFatShort => 'F';

  @override
  String get nutrientCarbsShort => 'C';

  @override
  String get dailyTotal => 'Daily Total';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get fatLabel => 'Fat';

  @override
  String get carbsLabel => 'Carbs';

  @override
  String get aiGenerating => 'AI is generating your meal plan...';

  @override
  String get mayTakeFewSeconds => 'This may take a few seconds';
}
