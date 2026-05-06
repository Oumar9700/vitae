import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/authentication/domain/entities/user_profile.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1 - Identité
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Step 2 - Sécurité
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  int _passwordStrength = 0;

  // Step 3 - Profil physique
  String _sexe = 'M';
  final _ageCtrl = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _tailleCtrl = TextEditingController();

  // Step 4 - Objectifs
  final _poidsObjectifCtrl = TextEditingController();
  final _delaiCtrl = TextEditingController(text: '12');
  String _niveauActivite = 'modere';

  // Step 5 - Santé
  final List<String> _conditionsSante = [];
  final List<String> _allergies = [];
  String _regime = 'omnivore';

  final List<GlobalKey<FormState>> _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final List<String> _conditionsOptions = ['Diabète', 'Hypertension', 'Cholestérol', 'Hypothyroïdie', 'Maladie cœliaque'];
  final List<String> _regimeOptions = ['Omnivore', 'Végétarien', 'Végan', 'Pescatarien', 'Sans gluten', 'Autre'];
  final Map<String, String> _activiteLabels = {
    'sedentaire': 'Sédentaire (peu/pas d\'exercice)',
    'leger': 'Léger (1-3j/semaine)',
    'modere': 'Modéré (3-5j/semaine)',
    'actif': 'Actif (6-7j/semaine)',
    'tres_actif': 'Très actif (sport intensif)',
  };

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _ageCtrl.dispose();
    _poidsCtrl.dispose();
    _tailleCtrl.dispose();
    _poidsObjectifCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        _submit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  void _submit() {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: '',
      email: _emailCtrl.text.trim(),
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      sexe: _sexe,
      age: int.tryParse(_ageCtrl.text) ?? 25,
      poidsKg: double.tryParse(_poidsCtrl.text.replaceAll(',', '.')) ?? 70,
      tailleCm: int.tryParse(_tailleCtrl.text) ?? 170,
      poidsObjectifKg: double.tryParse(_poidsObjectifCtrl.text.replaceAll(',', '.')) ?? 70,
      delaiSemaines: int.tryParse(_delaiCtrl.text) ?? 12,
      niveauActivite: _niveauActivite,
      conditionsSante: _conditionsSante,
      allergies: _allergies,
      regime: _regime.toLowerCase(),
      createdAt: now,
      updatedAt: now,
    );

    context.read<AuthBloc>().add(AuthSignupRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          profile: profile,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                            onPressed: _prevStep,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Étape ${_currentStep + 1} sur $_totalSteps',
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: (_currentStep + 1) / _totalSteps,
                                  backgroundColor: AppColors.border,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                      _buildStep4(),
                      _buildStep5(),
                    ],
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: PrimaryButton(
                    label: _currentStep == _totalSteps - 1 ? 'Créer mon compte' : 'Continuer',
                    onPressed: _nextStep,
                    isLoading: isLoading,
                    icon: _currentStep == _totalSteps - 1 ? Icons.check_rounded : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qui es-tu? 👤', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text('Commence par te présenter', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            VitaeTextField(label: 'Prénom', hint: 'Marie', controller: _prenomCtrl, validator: (v) => Validators.required(v, 'Prénom'), prefixIcon: Icons.person_outline),
            const SizedBox(height: 20),
            VitaeTextField(label: 'Nom', hint: 'Dupont', controller: _nomCtrl, validator: (v) => Validators.required(v, 'Nom'), prefixIcon: Icons.person_outline),
            const SizedBox(height: 20),
            VitaeTextField(label: 'Email', hint: 'marie@email.com', controller: _emailCtrl, validator: Validators.email, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sécurise ton compte 🔐', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text('Crée un mot de passe solide', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            VitaeTextField(
              label: 'Mot de passe',
              hint: '••••••••',
              controller: _passwordCtrl,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: Validators.password,
              onChanged: (v) => setState(() => _passwordStrength = Validators.passwordStrength(v)),
            ),
            const SizedBox(height: 10),
            PasswordStrengthIndicator(strength: _passwordStrength),
            const SizedBox(height: 20),
            VitaeTextField(
              label: 'Confirmer le mot de passe',
              hint: '••••••••',
              controller: _confirmPasswordCtrl,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ton profil physique 📏', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text('Pour calculer tes besoins précis', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            Text('Sexe', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                _sexeChip('M', 'Homme', Icons.male),
                const SizedBox(width: 12),
                _sexeChip('F', 'Femme', Icons.female),
                const SizedBox(width: 12),
                _sexeChip('Autre', 'Autre', Icons.person_outline),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: VitaeTextField(
                    label: 'Âge',
                    hint: '25',
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    validator: Validators.age,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Icons.cake_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: VitaeTextField(
                    label: 'Taille (cm)',
                    hint: '170',
                    controller: _tailleCtrl,
                    keyboardType: TextInputType.number,
                    validator: Validators.height,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: Icons.height,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            VitaeTextField(
              label: 'Poids actuel (kg)',
              hint: '70.0',
              controller: _poidsCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.weight,
              prefixIcon: Icons.monitor_weight_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tes objectifs 🎯', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text('Définissons ton plan personnalisé', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            VitaeTextField(
              label: 'Poids objectif (kg)',
              hint: '65.0',
              controller: _poidsObjectifCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.weight,
              prefixIcon: Icons.flag_outlined,
            ),
            const SizedBox(height: 20),

            VitaeTextField(
              label: 'Délai pour atteindre l\'objectif (semaines)',
              hint: '12',
              controller: _delaiCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icons.calendar_today_outlined,
              validator: (v) {
                final weeks = int.tryParse(v ?? '');
                if (weeks == null || weeks < 4 || weeks > 52) return 'Entre 4 et 52 semaines';
                return null;
              },
            ),
            const SizedBox(height: 20),

            Text('Niveau d\'activité physique', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ..._activiteLabels.entries.map((e) => _activiteOption(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5() {
    final allergyCtrl = TextEditingController();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKeys[4],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Santé & Alimentation 🌿', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text('Pour personnaliser tes recommandations', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            Text('Régime alimentaire', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _regimeOptions.map((r) => ChoiceChip(
                label: Text(r),
                selected: _regime.toLowerCase() == r.toLowerCase(),
                onSelected: (_) => setState(() => _regime = r.toLowerCase()),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _regime.toLowerCase() == r.toLowerCase() ? Colors.white : AppColors.textPrimary),
              )).toList(),
            ),
            const SizedBox(height: 24),

            Text('Conditions de santé (optionnel)', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _conditionsOptions.map((c) {
                final key = c.toLowerCase().replaceAll(' ', '_');
                final selected = _conditionsSante.contains(key);
                return FilterChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (v) => setState(() => v ? _conditionsSante.add(key) : _conditionsSante.remove(key)),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text('Allergies (optionnel)', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: allergyCtrl,
                    decoration: InputDecoration(hintText: 'Ex: arachide, lait...', hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary)),
                    style: AppTypography.body,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (v) {
                      if (v.isNotEmpty) {
                        setState(() => _allergies.add(v.trim()));
                        allergyCtrl.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  onPressed: () {
                    if (allergyCtrl.text.isNotEmpty) {
                      setState(() => _allergies.add(allergyCtrl.text.trim()));
                      allergyCtrl.clear();
                    }
                  },
                ),
              ],
            ),
            if (_allergies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allergies.map((a) => Chip(
                  label: Text(a),
                  onDeleted: () => setState(() => _allergies.remove(a)),
                  deleteIconColor: AppColors.error,
                  backgroundColor: AppColors.errorLight,
                )).toList(),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sexeChip(String value, String label, IconData icon) {
    final selected = _sexe == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sexe = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryPale : AppColors.bgLight,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.label.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activiteOption(String value, String label) {
    final selected = _niveauActivite == value;
    return GestureDetector(
      onTap: () => setState(() => _niveauActivite = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPale : AppColors.bgLight,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.body.copyWith(color: selected ? AppColors.primary : AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }
}
