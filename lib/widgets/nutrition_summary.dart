import 'package:flutter/material.dart';
import '../models/meal_plan.dart';

class NutritionSummary extends StatelessWidget {
  final NutritionInfo nutrition;

  const NutritionSummary({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Daily Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientColumn(
                  label: 'Calories',
                  value: '${nutrition.calories.round()}',
                  unit: 'kcal',
                  color: Colors.green[700]!,
                ),
                _NutrientColumn(
                  label: 'Protein',
                  value: '${nutrition.protein.round()}',
                  unit: 'g',
                  color: Colors.red[400]!,
                ),
                _NutrientColumn(
                  label: 'Fat',
                  value: '${nutrition.fat.round()}',
                  unit: 'g',
                  color: Colors.orange[400]!,
                ),
                _NutrientColumn(
                  label: 'Carbs',
                  value: '${nutrition.carbs.round()}',
                  unit: 'g',
                  color: Colors.blue[400]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientColumn extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutrientColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
