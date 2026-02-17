import 'package:flutter/material.dart';
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

    final groqKey = await _storageService.getGroqApiKey();
    if (groqKey == null || groqKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Groq API key in Settings first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profile = _buildProfile();
    await _storageService.saveUserProfile(profile);

    setState(() => _isLoading = true);

    try {
      final groqService = GroqService(apiKey: groqKey);
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
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Meal Planner'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Goal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'weight_loss', label: Text('Weight Loss'), icon: Icon(Icons.trending_down)),
                ButtonSegment(value: 'muscle_gain', label: Text('Muscle'), icon: Icon(Icons.fitness_center)),
                ButtonSegment(value: 'health', label: Text('Health'), icon: Icon(Icons.favorite)),
              ],
              selected: {_goal},
              onSelectionChanged: (val) => setState(() => _goal = val.first),
            ),

            const SizedBox(height: 20),
            Text('Gender', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'male', label: Text('Male'), icon: Icon(Icons.male)),
                ButtonSegment(value: 'female', label: Text('Female'), icon: Icon(Icons.female)),
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
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      suffixText: 'yrs',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final age = int.tryParse(v ?? '');
                      if (age == null || age < 10 || age > 120) return 'Invalid';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final w = double.tryParse(v ?? '');
                      if (w == null || w < 20 || w > 300) return 'Invalid';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final h = double.tryParse(v ?? '');
                      if (h == null || h < 100 || h > 250) return 'Invalid';
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
            Text('Activity Level', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _activityLevel,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sedentary (little/no exercise)')),
                DropdownMenuItem(value: 'light', child: Text('Light activity (1-3 days/week)')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate (3-5 days/week)')),
                DropdownMenuItem(value: 'active', child: Text('Active (6-7 days/week)')),
                DropdownMenuItem(value: 'very_active', child: Text('Very active (daily)')),
              ],
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),

            const SizedBox(height: 20),
            Text('Dietary Restrictions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildRestrictionChip('vegetarian', 'Vegetarian'),
                _buildRestrictionChip('vegan', 'Vegan'),
                _buildRestrictionChip('gluten_free', 'Gluten-Free'),
                _buildRestrictionChip('lactose_free', 'Lactose-Free'),
                _buildRestrictionChip('keto', 'Keto'),
                _buildRestrictionChip('halal', 'Halal'),
              ],
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                hintText: 'nuts, seafood...',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 20),
            Text(
              'Meals per day: $_mealsPerDay',
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
              label: const Text('Generate Meal Plan'),
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
