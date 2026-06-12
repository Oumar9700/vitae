import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/constants/app_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/auth_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _poidsCtrl;
  late final TextEditingController _tailleCtrl;
  late final TextEditingController _poidsObjectifCtrl;
  late final TextEditingController _delaiCtrl;

  // State
  late String _sexe;
  late String _niveauActivite;
  bool _saving = false;

  static const Map<String, String> _activityLabels = {
    'sedentaire':  'Sédentaire',
    'leger':       'Légèrement actif',
    'modere':      'Modérément actif',
    'actif':       'Actif',
    'tres_actif':  'Très actif',
  };

  static const Map<String, String> _activityDescriptions = {
    'sedentaire':  'Peu ou pas d\'exercice, travail de bureau',
    'leger':       '1–3 jours/semaine d\'exercice léger',
    'modere':      '3–5 jours/semaine d\'exercice modéré',
    'actif':       '6–7 jours/semaine d\'exercice intense',
    'tres_actif':  'Sportif professionnel ou travail physique',
  };

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _prenomCtrl        = TextEditingController(text: u.prenom);
    _nomCtrl           = TextEditingController(text: u.nom);
    _ageCtrl           = TextEditingController(text: u.age.toString());
    _poidsCtrl         = TextEditingController(text: u.poidsKg.toStringAsFixed(1));
    _tailleCtrl        = TextEditingController(text: u.tailleCm.toString());
    _poidsObjectifCtrl = TextEditingController(text: u.poidsObjectifKg.toStringAsFixed(1));
    _delaiCtrl         = TextEditingController(text: u.delaiSemaines.toString());
    _sexe              = u.sexe;
    _niveauActivite    = u.niveauActivite;
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _ageCtrl.dispose();
    _poidsCtrl.dispose();
    _tailleCtrl.dispose();
    _poidsObjectifCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  // ── Derived live preview ────────────────────────────────────────────────

  double? get _livePoids => double.tryParse(_poidsCtrl.text.replaceAll(',', '.'));
  int?    get _liveTaille => int.tryParse(_tailleCtrl.text);

  double? get _liveBmi {
    final p = _livePoids;
    final t = _liveTaille;
    if (p == null || t == null || t == 0) return null;
    return p / ((t / 100) * (t / 100));
  }

  String get _liveBmiCategory {
    final bmi = _liveBmi;
    if (bmi == null) return '';
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25)   return 'Poids normal';
    if (bmi < 30)   return 'Surpoids';
    return 'Obésité';
  }

  Color get _liveBmiColor {
    final bmi = _liveBmi;
    if (bmi == null) return AppColors.textSecondary;
    if (bmi < 18.5 || bmi >= 30) return AppColors.error;
    if (bmi < 25) return AppColors.nutritionGood;
    return AppColors.warning;
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.user.copyWith(
      prenom:          _prenomCtrl.text.trim(),
      nom:             _nomCtrl.text.trim(),
      sexe:            _sexe,
      age:             int.parse(_ageCtrl.text),
      poidsKg:         double.parse(_poidsCtrl.text.replaceAll(',', '.')),
      tailleCm:        int.parse(_tailleCtrl.text),
      poidsObjectifKg: double.parse(_poidsObjectifCtrl.text.replaceAll(',', '.')),
      delaiSemaines:   int.parse(_delaiCtrl.text),
      niveauActivite:  _niveauActivite,
      updatedAt:       DateTime.now(),
    );

    context.read<AuthBloc>().add(AuthProfileUpdateRequested(updated));
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, __) => _saving,
      listener: (context, state) {
        setState(() => _saving = false);
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour ✓'),
              backgroundColor: AppColors.nutritionGood,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgWhite,
        appBar: AppBar(
          title: Text('Modifier mon profil', style: AppTypography.h3),
          leading: IconButton(
            icon: const Icon(AppIcons.back, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section: Identité ──────────────────────────────
                _SectionHeader(icon: AppIcons.profile, label: 'Identité'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: VitaeTextField(
                        label: 'Prénom',
                        controller: _prenomCtrl,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => Validators.required(v, 'Prénom'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VitaeTextField(
                        label: 'Nom',
                        controller: _nomCtrl,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => Validators.required(v, 'Nom'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sexe
                Text('Sexe biologique', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SexeChip(value: 'M',     label: 'Homme',  selected: _sexe == 'M',     onTap: () => setState(() => _sexe = 'M')),
                    const SizedBox(width: 8),
                    _SexeChip(value: 'F',     label: 'Femme',  selected: _sexe == 'F',     onTap: () => setState(() => _sexe = 'F')),
                    const SizedBox(width: 8),
                    _SexeChip(value: 'Autre', label: 'Autre',  selected: _sexe == 'Autre', onTap: () => setState(() => _sexe = 'Autre')),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section: Mensurations ──────────────────────────
                _SectionHeader(icon: AppIcons.unit, label: 'Mensurations'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: VitaeTextField(
                        label: 'Âge (ans)',
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: Validators.age,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VitaeTextField(
                        label: 'Taille (cm)',
                        controller: _tailleCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: Validators.height,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: VitaeTextField(
                        label: 'Poids actuel (kg)',
                        controller: _poidsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        validator: Validators.weight,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Live BMI preview
                    Expanded(child: _BmiPreview(bmi: _liveBmi, category: _liveBmiCategory, color: _liveBmiColor)),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section: Objectif ──────────────────────────────
                _SectionHeader(icon: AppIcons.calories, label: 'Objectif'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: VitaeTextField(
                        label: 'Poids objectif (kg)',
                        controller: _poidsObjectifCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        validator: Validators.weight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VitaeTextField(
                        label: 'Délai (semaines)',
                        controller: _delaiCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          final w = int.tryParse(v ?? '');
                          if (w == null) return 'Invalide';
                          if (w < AppConstants.weeksMin || w > AppConstants.weeksMax) {
                            return '${AppConstants.weeksMin}–${AppConstants.weeksMax} semaines';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section: Activité ──────────────────────────────
                _SectionHeader(icon: AppIcons.protein, label: 'Niveau d\'activité'),
                const SizedBox(height: 12),

                ..._activityLabels.entries.map((entry) {
                  final isSelected = _niveauActivite == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _niveauActivite = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryPale : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value,
                                  style: AppTypography.label.copyWith(
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _activityDescriptions[entry.key] ?? '',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Text(
                              '× ${AppConstants.activityFactors[entry.key]?.toStringAsFixed(2) ?? ''}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),

                // ── Save button ────────────────────────────────────
                PrimaryButton(
                  label: _saving ? 'Sauvegarde…' : 'Sauvegarder',
                  onPressed: _saving ? null : _save,
                  icon: AppIcons.save,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.h3.copyWith(fontSize: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: AppColors.primaryLight, thickness: 1)),
      ],
    );
  }
}

// ─── Sexe chip ────────────────────────────────────────────────────────────────

class _SexeChip extends StatelessWidget {
  final String value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SexeChip({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPale : AppColors.bgLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Live BMI preview ────────────────────────────────────────────────────────

class _BmiPreview extends StatelessWidget {
  final double? bmi;
  final String category;
  final Color color;

  const _BmiPreview({required this.bmi, required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bmi != null ? color.withValues(alpha: 0.08) : AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bmi != null ? color.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('IMC', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          if (bmi != null) ...[
            Text(
              bmi!.toStringAsFixed(1),
              style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
            Text(
              category,
              style: AppTypography.caption.copyWith(color: color, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ] else
            Text('—', style: AppTypography.body.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
