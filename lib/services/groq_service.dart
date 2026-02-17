import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import 'logger_service.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  final String apiKey;

  GroqService({required this.apiKey});

  String _buildPrompt(UserProfile profile) {
    final goalMap = {
      'weight_loss': 'weight loss (caloric deficit)',
      'muscle_gain': 'muscle gain (caloric surplus with high protein)',
      'health': 'general health and balanced nutrition',
    };

    final activityMap = {
      'sedentary': 'sedentary (little or no exercise)',
      'light': 'lightly active (1-3 days/week)',
      'moderate': 'moderately active (3-5 days/week)',
      'active': 'active (6-7 days/week)',
      'very_active': 'very active (intense exercise daily)',
    };

    final restrictions = profile.dietaryRestrictions.isNotEmpty
        ? 'Dietary restrictions: ${profile.dietaryRestrictions.join(', ')}.'
        : 'No specific dietary restrictions.';

    final allergies = profile.allergies.isNotEmpty
        ? 'Allergies: ${profile.allergies}.'
        : 'No known allergies.';

    return '''You are a professional nutritionist AI. Create a detailed daily meal plan.

User profile:
- Goal: ${goalMap[profile.goal] ?? profile.goal}
- Gender: ${profile.gender}
- Age: ${profile.age} years
- Weight: ${profile.weight} kg
- Height: ${profile.height} cm
- Activity level: ${activityMap[profile.activityLevel] ?? profile.activityLevel}
- Number of meals per day: ${profile.mealsPerDay}
- $restrictions
- $allergies

Generate a complete daily meal plan with exactly ${profile.mealsPerDay} meals.
For each meal, provide realistic calorie and macronutrient values.

You MUST respond with ONLY a valid JSON object (no markdown, no extra text) in this exact format:
{
  "plan_name": "descriptive name for the plan",
  "total_calories": <total daily calories as number>,
  "meals": [
    {
      "type": "breakfast/lunch/dinner/snack",
      "name": "meal name in Russian",
      "search_name": "meal name in English for recipe search",
      "description": "brief description of the meal",
      "calories": <number>,
      "protein": <grams as number>,
      "carbs": <grams as number>,
      "fat": <grams as number>,
      "ingredients": ["ingredient1", "ingredient2", ...]
    }
  ]
}

Rules:
- Meal types should be distributed logically (breakfast, lunch, dinner, snacks)
- Calories should match the user's goal
- All nutritional values must be realistic
- Include 3-8 ingredients per meal
- "name" and "description" and "ingredients" should be in Russian
- "search_name" MUST be in English (used for recipe API search)
- Return ONLY the JSON, no other text''';
  }

  Future<MealPlan> generateMealPlan(UserProfile profile) async {
    final prompt = _buildPrompt(profile);
    final stopwatch = Stopwatch()..start();

    AppLogger.info(
      'Generating meal plan: goal=${profile.goal}, meals=${profile.mealsPerDay}, key=${AppLogger.maskKey(apiKey)}',
      source: 'Groq',
    );

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          AppLogger.info('Retry attempt $attempt/$_maxRetries', source: 'Groq');
        }

        final response = await http
            .post(
              Uri.parse(_baseUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
              body: jsonEncode({
                'model': _model,
                'messages': [
                  {
                    'role': 'system',
                    'content': 'You are a professional nutritionist. Always respond with valid JSON only.',
                  },
                  {
                    'role': 'user',
                    'content': prompt,
                  },
                ],
                'temperature': 0.7,
                'max_tokens': 2000,
                'response_format': {'type': 'json_object'},
              }),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          stopwatch.stop();
          AppLogger.info(
            'Meal plan generated successfully in ${stopwatch.elapsedMilliseconds}ms',
            source: 'Groq',
          );
          return _parseResponse(response.body, profile.goal);
        } else if (response.statusCode == 429) {
          AppLogger.warning('Rate limit hit (429), attempt $attempt', source: 'Groq');
          if (attempt < _maxRetries) {
            final waitSeconds = (attempt + 1) * 2;
            await Future.delayed(Duration(seconds: waitSeconds));
            continue;
          }
          throw GroqException(
            'Превышен лимит запросов. Попробуйте позже.',
            statusCode: 429,
          );
        } else if (response.statusCode == 401) {
          AppLogger.error('Invalid API key (401)', source: 'Groq');
          throw GroqException(
            'Неверный API-ключ Groq. Проверьте настройки.',
            statusCode: 401,
          );
        } else {
          final body = jsonDecode(response.body);
          final errorMsg = body['error']?['message'] ?? 'Unknown error';
          AppLogger.error('API error ${response.statusCode}: $errorMsg', source: 'Groq');
          throw GroqException(
            'Ошибка Groq API: $errorMsg',
            statusCode: response.statusCode,
          );
        }
      } on GroqException {
        rethrow;
      } catch (e) {
        AppLogger.error('Connection error on attempt $attempt: $e', source: 'Groq');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
          continue;
        }
        if (e.toString().contains('TimeoutException')) {
          throw GroqException('Таймаут запроса. Проверьте интернет-соединение.');
        }
        throw GroqException('Ошибка соединения: ${e.toString()}');
      }
    }

    throw GroqException('Не удалось получить ответ после $_maxRetries попыток.');
  }

  MealPlan _parseResponse(String responseBody, String goal) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final content = json['choices']?[0]?['message']?['content'] as String?;

      if (content == null || content.isEmpty) {
        throw GroqException('Пустой ответ от AI.');
      }

      String cleanContent = content.trim();
      // Remove markdown code blocks if present
      if (cleanContent.startsWith('```')) {
        cleanContent = cleanContent.replaceAll(RegExp(r'^```\w*\n?'), '');
        cleanContent = cleanContent.replaceAll(RegExp(r'\n?```$'), '');
        cleanContent = cleanContent.trim();
      }

      final planJson = jsonDecode(cleanContent) as Map<String, dynamic>;
      planJson['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      planJson['created_at'] = DateTime.now().toIso8601String();
      planJson['goal'] = goal;

      return MealPlan.fromJson(planJson);
    } catch (e) {
      if (e is GroqException) rethrow;
      AppLogger.error('Failed to parse AI response', source: 'Groq', error: e);
      throw GroqException('Ошибка парсинга ответа AI: ${e.toString()}');
    }
  }

  Future<bool> validateApiKey() async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': 'Hi'},
              ],
              'max_tokens': 5,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class GroqException implements Exception {
  final String message;
  final int? statusCode;

  GroqException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
