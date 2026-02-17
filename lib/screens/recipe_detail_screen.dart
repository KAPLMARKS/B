import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/spoonacular_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final SpoonacularRecipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logViewRecipe(recipeTitle: recipe.title);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: ListView(
        children: [
          if (recipe.image != null)
            Image.network(
              recipe.image!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                height: 220,
                child: Center(child: Icon(Icons.restaurant, size: 64)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (recipe.readyInMinutes != null) ...[
                      const Icon(Icons.timer, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${recipe.readyInMinutes} min'),
                      const SizedBox(width: 16),
                    ],
                    if (recipe.servings != null) ...[
                      const Icon(Icons.people, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${recipe.servings} servings'),
                    ],
                  ],
                ),
                if (recipe.summary != null && recipe.summary!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _stripHtml(recipe.summary!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (recipe.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map(
                    (ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('  \u2022  '),
                          Expanded(child: Text(ing.original)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (recipe.steps.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${step.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.step,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
