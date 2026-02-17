import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'meal_plan_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final _storageService = StorageService();
  List<MealPlan> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    setState(() => _isLoading = true);
    final plans = await _storageService.getSavedMealPlans();
    if (mounted) {
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
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

  Future<void> _deletePlan(MealPlan plan) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePlanTitle),
        content: Text(l10n.deletePlanConfirm(plan.planName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteMealPlan(plan.id);
      loadPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedPlans),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noSavedPlansYet,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.createPlanHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadPlans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final dateStr = DateFormat('MM/dd/yyyy HH:mm').format(plan.createdAt);
                      final nutrition = plan.totalNutrition;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            plan.planName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('$dateStr  |  ${_localizedGoalLabel(l10n, plan.goal)}'),
                              const SizedBox(height: 4),
                              Text(
                                '${nutrition.calories.round()} ${l10n.kcalUnit}  |  ${l10n.nutrientProteinShort}:${nutrition.protein.round()}${l10n.gramUnit}  ${l10n.nutrientFatShort}:${nutrition.fat.round()}${l10n.gramUnit}  ${l10n.nutrientCarbsShort}:${nutrition.carbs.round()}${l10n.gramUnit}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                l10n.mealsCount(plan.meals.length),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deletePlan(plan),
                          ),
                          onTap: () async {
                            final profile = await _storageService.getUserProfile();
                            if (!context.mounted) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealPlanScreen(
                                  mealPlan: plan,
                                  userProfile: profile ??
                                      const UserProfile(
                                        goal: 'health',
                                        gender: 'male',
                                        age: 25,
                                        weight: 70,
                                        height: 170,
                                        activityLevel: 'moderate',
                                        dietaryRestrictions: [],
                                        allergies: '',
                                        mealsPerDay: 3,
                                      ),
                                ),
                              ),
                            );
                            loadPlans();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
