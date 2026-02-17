class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  NutritionInfo operator +(NutritionInfo other) {
    return NutritionInfo(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
    );
  }
}

class Meal {
  final String type;
  final String name;
  final String searchName;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients;

  const Meal({
    required this.type,
    required this.name,
    required this.searchName,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
  });

  NutritionInfo get nutrition => NutritionInfo(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      type: json['type'] as String? ?? 'meal',
      name: json['name'] as String? ?? 'Unknown',
      searchName: json['search_name'] as String? ?? json['name'] as String? ?? 'meal',
      description: json['description'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'search_name': searchName,
        'description': description,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'ingredients': ingredients,
      };
}

class MealPlan {
  final String id;
  final String planName;
  final double totalCalories;
  final List<Meal> meals;
  final DateTime createdAt;
  final String goal;

  const MealPlan({
    required this.id,
    required this.planName,
    required this.totalCalories,
    required this.meals,
    required this.createdAt,
    required this.goal,
  });

  NutritionInfo get totalNutrition {
    if (meals.isEmpty) {
      return const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0);
    }
    return meals.map((m) => m.nutrition).reduce((a, b) => a + b);
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      planName: json['plan_name'] as String? ?? 'Meal Plan',
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      goal: json['goal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_name': planName,
        'total_calories': totalCalories,
        'meals': meals.map((m) => m.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'goal': goal,
      };
}
