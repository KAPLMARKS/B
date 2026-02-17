import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../services/groq_service.dart';
import '../services/storage_service.dart';
import '../widgets/loading_indicator.dart';
import 'meal_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  String _goal = 'health';
  String _gender = 'male';
  final _ageController = TextEditingController(text: '25');
  final _weightController = TextEditingController(text: '70');
  final _heightController = TextEditingController(text: '170');
  String _activityLevel = 'moderate';
  final List<String> _dietaryRestrictions = [];
  final _allergiesController = TextEditingController();
  int _mealsPerDay = 3;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final profile = await _storageService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _goal = profile.goal;
        _gender = profile.gender;
        _ageController.text = profile.age.toString();
        _weightController.text = profile.weight.toString();
        _heightController.text = profile.height.toString();
        _activityLevel = profile.activityLevel;
        _dietaryRestrictions.clear();
        _dietaryRestrictions.addAll(profile.dietaryRestrictions);
        _allergiesController.text = profile.allergies;
        _mealsPerDay = profile.mealsPerDay;
      });
    }
  }

  UserProfile _buildProfile() {
    return UserProfile(
      goal: _goal,
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 25,
      weight: double.tryParse(_weightController.text) ?? 70,
      height: double.tryParse(_heightController.text) ?? 170,
      activityLevel: _activityLevel,
      dietaryRestrictions: List.from(_dietaryRestrictions),
      allergies: _allergiesController.text.trim(),
      mealsPerDay: _mealsPerDay,
    );
  }

  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final groqKey = await _storageService.getGroqApiKey();
    final profile = _buildProfile();
    await _storageService.saveUserProfile(profile);

    setState(() => _isLoading = true);

    try {
      final groqService = GroqService(apiKey: groqKey!);
      final plan = await groqService.generateMealPlan(profile);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealPlanScreen(mealPlan: plan, userProfile: profile),
        ),
      );
    } on GroqException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.goalSectionTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'weight_loss', label: Text(l10n.goalWeightLoss), icon: const Icon(Icons.trending_down)),
                ButtonSegment(value: 'muscle_gain', label: Text(l10n.goalMuscle), icon: const Icon(Icons.fitness_center)),
                ButtonSegment(value: 'health', label: Text(l10n.goalHealth), icon: const Icon(Icons.favorite)),
              ],
              selected: {_goal},
              onSelectionChanged: (val) => setState(() => _goal = val.first),
            ),

            const SizedBox(height: 20),
            Text(l10n.genderSectionTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'male', label: Text(l10n.genderMale), icon: const Icon(Icons.male)),
                ButtonSegment(value: 'female', label: Text(l10n.genderFemale), icon: const Icon(Icons.female)),
              ],
              selected: {_gender},
              onSelectionChanged: (val) => setState(() => _gender = val.first),
            ),

            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                final fields = [
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: l10n.ageLabel,
                      suffixText: l10n.ageSuffix,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final age = int.tryParse(v ?? '');
                      if (age == null || age < 10 || age > 120) return l10n.invalidField;
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: l10n.weightLabel,
                      suffixText: l10n.weightSuffix,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final w = double.tryParse(v ?? '');
                      if (w == null || w < 20 || w > 300) return l10n.invalidField;
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: l10n.heightLabel,
                      suffixText: l10n.heightSuffix,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final h = double.tryParse(v ?? '');
                      if (h == null || h < 100 || h > 250) return l10n.invalidField;
                      return null;
                    },
                  ),
                ];

                if (isNarrow) {
                  return Column(
                    children: fields.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: f,
                    )).toList(),
                  );
                }
                return Row(
                  children: [
                    Expanded(child: fields[0]),
                    const SizedBox(width: 12),
                    Expanded(child: fields[1]),
                    const SizedBox(width: 12),
                    Expanded(child: fields[2]),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            Text(l10n.activityLevelTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _activityLevel,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'sedentary', child: Text(l10n.activitySedentary)),
                DropdownMenuItem(value: 'light', child: Text(l10n.activityLight)),
                DropdownMenuItem(value: 'moderate', child: Text(l10n.activityModerate)),
                DropdownMenuItem(value: 'active', child: Text(l10n.activityActive)),
                DropdownMenuItem(value: 'very_active', child: Text(l10n.activityVeryActive)),
              ],
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),

            const SizedBox(height: 20),
            Text(l10n.dietaryRestrictionsTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildRestrictionChip('vegetarian', l10n.dietVegetarian),
                _buildRestrictionChip('vegan', l10n.dietVegan),
                _buildRestrictionChip('gluten_free', l10n.dietGlutenFree),
                _buildRestrictionChip('lactose_free', l10n.dietLactoseFree),
                _buildRestrictionChip('keto', l10n.dietKeto),
                _buildRestrictionChip('halal', l10n.dietHalal),
              ],
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: _allergiesController,
              decoration: InputDecoration(
                labelText: l10n.allergiesLabel,
                hintText: l10n.allergiesHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 20),
            Text(
              l10n.mealsPerDay(_mealsPerDay),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _mealsPerDay.toDouble(),
              min: 3,
              max: 6,
              divisions: 3,
              label: _mealsPerDay.toString(),
              onChanged: (v) => setState(() => _mealsPerDay = v.round()),
            ),

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.auto_awesome),
              label: Text(l10n.generateMealPlan),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRestrictionChip(String value, String label) {
    final selected = _dietaryRestrictions.contains(value);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) {
        setState(() {
          if (isSelected) {
            _dietaryRestrictions.add(value);
          } else {
            _dietaryRestrictions.remove(value);
          }
        });
      },
    );
  }
}
