import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';

class SpoonacularRecipe {
  final int id;
  final String title;
  final String? image;
  final int? readyInMinutes;
  final int? servings;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final String? summary;

  const SpoonacularRecipe({
    required this.id,
    required this.title,
    this.image,
    this.readyInMinutes,
    this.servings,
    required this.ingredients,
    required this.steps,
    this.summary,
  });

  factory SpoonacularRecipe.fromSearchJson(Map<String, dynamic> json) {
    return SpoonacularRecipe(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      image: json['image'] as String?,
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      ingredients: [],
      steps: [],
      summary: null,
    );
  }

  factory SpoonacularRecipe.fromDetailJson(Map<String, dynamic> json) {
    final ingredients = (json['extendedIngredients'] as List<dynamic>?)
            ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final steps = <RecipeStep>[];
    final analyzedInstructions = json['analyzedInstructions'] as List<dynamic>?;
    if (analyzedInstructions != null && analyzedInstructions.isNotEmpty) {
      final instructionSteps =
          analyzedInstructions[0]['steps'] as List<dynamic>?;
      if (instructionSteps != null) {
        steps.addAll(
          instructionSteps
              .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>)),
        );
      }
    }

    return SpoonacularRecipe(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      image: json['image'] as String?,
      readyInMinutes: json['readyInMinutes'] as int?,
      servings: json['servings'] as int?,
      ingredients: ingredients,
      steps: steps,
      summary: json['summary'] as String?,
    );
  }
}

class RecipeIngredient {
  final String name;
  final double amount;
  final String unit;
  final String original;

  const RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.original,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      original: json['original'] as String? ?? '',
    );
  }
}

class RecipeStep {
  final int number;
  final String step;

  const RecipeStep({required this.number, required this.step});

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      number: json['number'] as int? ?? 0,
      step: json['step'] as String? ?? '',
    );
  }
}

class SpoonacularService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  static const Duration _timeout = Duration(seconds: 15);

  final String apiKey;

  SpoonacularService({required this.apiKey});

  Future<List<SpoonacularRecipe>> searchRecipes(String query,
      {int number = 5}) async {
    AppLogger.info('Searching recipes: query="$query", count=$number', source: 'Spoonacular');

    try {
      final uri = Uri.parse('$_baseUrl/recipes/complexSearch').replace(
        queryParameters: {
          'apiKey': apiKey,
          'query': query,
          'number': number.toString(),
          'addRecipeInformation': 'true',
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = json['results'] as List<dynamic>? ?? [];
        AppLogger.info('Found ${results.length} recipes for "$query"', source: 'Spoonacular');
        return results
            .map((e) =>
                SpoonacularRecipe.fromSearchJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        AppLogger.error('Invalid API key (401)', source: 'Spoonacular');
        throw SpoonacularException(
          'Неверный API-ключ Spoonacular. Проверьте настройки.',
          statusCode: 401,
        );
      } else if (response.statusCode == 402) {
        AppLogger.warning('Daily quota exhausted (402)', source: 'Spoonacular');
        throw SpoonacularException(
          'Исчерпан дневной лимит Spoonacular API.',
          statusCode: 402,
        );
      } else {
        AppLogger.error('API error: ${response.statusCode}', source: 'Spoonacular');
        throw SpoonacularException(
          'Ошибка Spoonacular API: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SpoonacularException {
      rethrow;
    } catch (e) {
      AppLogger.error('Connection error: $e', source: 'Spoonacular');
      if (e.toString().contains('TimeoutException')) {
        throw SpoonacularException('Таймаут запроса к Spoonacular.');
      }
      throw SpoonacularException('Ошибка соединения: ${e.toString()}');
    }
  }

  Future<SpoonacularRecipe> getRecipeDetails(int recipeId) async {
    AppLogger.info('Fetching recipe details: id=$recipeId', source: 'Spoonacular');
    try {
      final uri = Uri.parse('$_baseUrl/recipes/$recipeId/information').replace(
        queryParameters: {
          'apiKey': apiKey,
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SpoonacularRecipe.fromDetailJson(json);
      } else if (response.statusCode == 401) {
        throw SpoonacularException(
          'Неверный API-ключ Spoonacular.',
          statusCode: 401,
        );
      } else if (response.statusCode == 402) {
        throw SpoonacularException(
          'Исчерпан дневной лимит Spoonacular API.',
          statusCode: 402,
        );
      } else {
        throw SpoonacularException(
          'Ошибка получения рецепта: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SpoonacularException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw SpoonacularException('Таймаут запроса к Spoonacular.');
      }
      throw SpoonacularException('Ошибка соединения: ${e.toString()}');
    }
  }

  Future<bool> validateApiKey() async {
    try {
      final uri = Uri.parse('$_baseUrl/recipes/complexSearch').replace(
        queryParameters: {
          'apiKey': apiKey,
          'query': 'test',
          'number': '1',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class SpoonacularException implements Exception {
  final String message;
  final int? statusCode;

  SpoonacularException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
