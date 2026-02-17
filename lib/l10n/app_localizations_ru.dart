// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AI Планировщик питания';

  @override
  String get navPlanner => 'Планировщик';

  @override
  String get navHistory => 'История';

  @override
  String get goalSectionTitle => 'Цель';

  @override
  String get goalWeightLoss => 'Похудение';

  @override
  String get goalMuscle => 'Мышцы';

  @override
  String get goalMuscleGain => 'Набор массы';

  @override
  String get goalHealth => 'Здоровье';

  @override
  String get genderSectionTitle => 'Пол';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get ageLabel => 'Возраст';

  @override
  String get ageSuffix => 'лет';

  @override
  String get weightLabel => 'Вес';

  @override
  String get weightSuffix => 'кг';

  @override
  String get heightLabel => 'Рост';

  @override
  String get heightSuffix => 'см';

  @override
  String get invalidField => 'Некорректно';

  @override
  String get activityLevelTitle => 'Уровень активности';

  @override
  String get activitySedentary => 'Сидячий (мало/без упражнений)';

  @override
  String get activityLight => 'Лёгкая активность (1-3 дня/нед.)';

  @override
  String get activityModerate => 'Умеренная (3-5 дней/нед.)';

  @override
  String get activityActive => 'Активный (6-7 дней/нед.)';

  @override
  String get activityVeryActive => 'Очень активный (ежедневно)';

  @override
  String get dietaryRestrictionsTitle => 'Диетические ограничения';

  @override
  String get dietVegetarian => 'Вегетарианство';

  @override
  String get dietVegan => 'Веганство';

  @override
  String get dietGlutenFree => 'Без глютена';

  @override
  String get dietLactoseFree => 'Без лактозы';

  @override
  String get dietKeto => 'Кето';

  @override
  String get dietHalal => 'Халяль';

  @override
  String get allergiesLabel => 'Аллергии';

  @override
  String get allergiesHint => 'орехи, морепродукты...';

  @override
  String mealsPerDay(int count) {
    return 'Приёмов пищи в день: $count';
  }

  @override
  String get generateMealPlan => 'Сгенерировать план питания';

  @override
  String errorGeneric(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get generating => 'Генерация...';

  @override
  String get regeneratingPlan => 'Перегенерация плана...';

  @override
  String get planSaved => 'План сохранён';

  @override
  String get noRecipesFound => 'Рецепты не найдены';

  @override
  String get chooseRecipe => 'Выберите рецепт';

  @override
  String get cancel => 'Отмена';

  @override
  String minutesShort(int minutes) {
    return '$minutes мин';
  }

  @override
  String failedToLoadRecipe(String error) {
    return 'Не удалось загрузить рецепт: $error';
  }

  @override
  String goalWithValue(String goal) {
    return 'Цель: $goal';
  }

  @override
  String get savePlanTooltip => 'Сохранить план';

  @override
  String get regenerateTooltip => 'Перегенерировать';

  @override
  String get newPlan => 'Новый план';

  @override
  String get saved => 'Сохранено';

  @override
  String get save => 'Сохранить';

  @override
  String get savedPlans => 'Сохранённые планы';

  @override
  String get noSavedPlansYet => 'Нет сохранённых планов';

  @override
  String get createPlanHint => 'Создайте план на главном экране';

  @override
  String get deletePlanTitle => 'Удалить план?';

  @override
  String deletePlanConfirm(String name) {
    return 'Удалить \"$name\"?';
  }

  @override
  String get delete => 'Удалить';

  @override
  String mealsCount(int count) {
    return '$count приёмов пищи';
  }

  @override
  String get ingredients => 'Ингредиенты';

  @override
  String get instructions => 'Инструкции';

  @override
  String servingsCount(int count) {
    return '$count порций';
  }

  @override
  String get mealBreakfast => 'Завтрак';

  @override
  String get mealLunch => 'Обед';

  @override
  String get mealDinner => 'Ужин';

  @override
  String get mealSnack => 'Перекус';

  @override
  String get mealSecondBreakfast => 'Второй завтрак';

  @override
  String get kcalUnit => 'ккал';

  @override
  String get gramUnit => 'г';

  @override
  String get findRecipe => 'Найти рецепт';

  @override
  String get nutrientProteinShort => 'Б';

  @override
  String get nutrientFatShort => 'Ж';

  @override
  String get nutrientCarbsShort => 'У';

  @override
  String get dailyTotal => 'Итого за день';

  @override
  String get caloriesLabel => 'Калории';

  @override
  String get proteinLabel => 'Белки';

  @override
  String get fatLabel => 'Жиры';

  @override
  String get carbsLabel => 'Углеводы';

  @override
  String get aiGenerating => 'ИИ генерирует план питания...';

  @override
  String get mayTakeFewSeconds => 'Это может занять несколько секунд';
}
