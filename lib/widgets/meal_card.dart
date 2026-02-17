import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/meal_plan.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onFindRecipe;

  const MealCard({
    super.key,
    required this.meal,
    this.onFindRecipe,
  });

  String _getMealTypeLabel(AppLocalizations l10n, String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return l10n.mealBreakfast;
      case 'lunch':
        return l10n.mealLunch;
      case 'dinner':
        return l10n.mealDinner;
      case 'snack':
        return l10n.mealSnack;
      case 'second_breakfast':
        return l10n.mealSecondBreakfast;
      default:
        return type;
    }
  }

  IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getMealIcon(meal.type), size: 24, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _getMealTypeLabel(l10n, meal.type),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${meal.calories.round()} ${l10n.kcalUnit}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (meal.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meal.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _NutrientChip(label: l10n.nutrientProteinShort, value: meal.protein, color: Colors.red[400]!),
                const SizedBox(width: 8),
                _NutrientChip(label: l10n.nutrientFatShort, value: meal.fat, color: Colors.orange[400]!),
                const SizedBox(width: 8),
                _NutrientChip(label: l10n.nutrientCarbsShort, value: meal.carbs, color: Colors.blue[400]!),
              ],
            ),
            if (meal.ingredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: meal.ingredients
                    .map((i) => Chip(
                          label: Text(i, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (onFindRecipe != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onFindRecipe,
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(l10n.findRecipe),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _NutrientChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: ${value.round()}${l10n.gramUnit}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
