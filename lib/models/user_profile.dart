class UserProfile {
  final String goal; // weight_loss, muscle_gain, health
  final String gender; // male, female
  final int age;
  final double weight; // kg
  final double height; // cm
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final List<String> dietaryRestrictions; // vegetarian, vegan, gluten_free, lactose_free
  final String allergies;
  final int mealsPerDay; // 3-6

  const UserProfile({
    required this.goal,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.mealsPerDay,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      goal: json['goal'] as String? ?? 'health',
      gender: json['gender'] as String? ?? 'male',
      age: json['age'] as int? ?? 25,
      weight: (json['weight'] as num?)?.toDouble() ?? 70,
      height: (json['height'] as num?)?.toDouble() ?? 170,
      activityLevel: json['activity_level'] as String? ?? 'moderate',
      dietaryRestrictions: (json['dietary_restrictions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allergies: json['allergies'] as String? ?? '',
      mealsPerDay: json['meals_per_day'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'gender': gender,
        'age': age,
        'weight': weight,
        'height': height,
        'activity_level': activityLevel,
        'dietary_restrictions': dietaryRestrictions,
        'allergies': allergies,
        'meals_per_day': mealsPerDay,
      };

  String get goalDisplayName => goalLabel(goal);

  static String goalLabel(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'health':
        return 'Health';
      default:
        return goal;
    }
  }

  String get activityDisplayName {
    switch (activityLevel) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Light Activity';
      case 'moderate':
        return 'Moderate';
      case 'active':
        return 'Active';
      case 'very_active':
        return 'Very Active';
      default:
        return activityLevel;
    }
  }
}
