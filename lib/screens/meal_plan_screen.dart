import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../services/groq_service.dart';
import '../services/spoonacular_service.dart';
import '../services/storage_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/nutrition_summary.dart';
import '../widgets/loading_indicator.dart';
import 'recipe_detail_screen.dart';

class MealPlanScreen extends StatefulWidget {
  final MealPlan mealPlan;
  final UserProfile userProfile;

  const MealPlanScreen({
    super.key,
    required this.mealPlan,
    required this.userProfile,
  });

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _storageService = StorageService();
  late MealPlan _currentPlan;
  bool _isRegenerating = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.mealPlan;
  }

  Future<void> _regeneratePlan() async {
    final groqKey = await _storageService.getGroqApiKey();

    setState(() => _isRegenerating = true);

    try {
      final groqService = GroqService(apiKey: groqKey!);
      final newPlan = await groqService.generateMealPlan(widget.userProfile);
      if (mounted) {
        setState(() {
          _currentPlan = newPlan;
          _isSaved = false;
        });
      }
    } on GroqException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  Future<void> _savePlan() async {
    await _storageService.saveMealPlan(_currentPlan);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.planSaved),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _findRecipe(Meal meal) async {
    final spoonacularKey = await _storageService.getSpoonacularApiKey();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = SpoonacularService(apiKey: spoonacularKey!);
      final recipes = await service.searchRecipes(meal.name, number: 5);

      if (!mounted) return;
      Navigator.pop(context);

      final l10n = AppLocalizations.of(context)!;

      if (recipes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noRecipesFound)),
        );
        return;
      }

      final selected = await showDialog<SpoonacularRecipe>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.chooseRecipe),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: recipes.length,
              itemBuilder: (_, i) {
                final recipe = recipes[i];
                return ListTile(
                  leading: recipe.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe.image!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.restaurant, size: 56),
                          ),
                        )
                      : const Icon(Icons.restaurant, size: 56),
                  title: Text(recipe.title),
                  subtitle: recipe.readyInMinutes != null
                      ? Text(l10n.minutesShort(recipe.readyInMinutes!))
                      : null,
                  onTap: () => Navigator.pop(ctx, recipe),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );

      if (selected != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final detailedRecipe = await service.getRecipeDetails(selected.id);
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: detailedRecipe),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToLoadRecipe(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on SpoonacularException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _localizedGoalLabel(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'weight_loss':
        return l10n.goalWeightLoss;
      case 'muscle_gain':
        return l10n.goalMuscleGain;
      case 'health':
        return l10n.goalHealth;
      default:
        return goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isRegenerating) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.generating)),
        body: LoadingIndicator(message: l10n.regeneratingPlan),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPlan.planName),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _savePlan,
            tooltip: l10n.savePlanTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _regeneratePlan,
            tooltip: l10n.regenerateTooltip,
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              l10n.goalWithValue(
                _localizedGoalLabel(l10n, widget.userProfile.goal),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          NutritionSummary(nutrition: _currentPlan.totalNutrition),
          const SizedBox(height: 8),
          ..._currentPlan.meals.map(
            (meal) => MealCard(
              meal: meal,
              onFindRecipe: () => _findRecipe(meal),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _regeneratePlan,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.newPlan),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaved ? null : _savePlan,
                    icon: const Icon(Icons.save),
                    label: Text(_isSaved ? l10n.saved : l10n.save),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
