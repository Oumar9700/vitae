import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../../../shared/constants/app_icons.dart';
import '../../../../shared/services/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/nutrition_info_widget.dart';
import '../../../authentication/domain/entities/user_profile.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text('Profil & Réglages', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 20),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          final targets = NutritionCalculator.calculateTargets(user);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                _ProfileCard(user: user),
                const SizedBox(height: 24),

                // Nutrition targets
                Text('Besoins calculés', style: AppTypography.h3),
                const SizedBox(height: 12),
                _NutritionTargetsCard(targets: targets),
                const SizedBox(height: 24),

                // BMR/TDEE info
                Text('Métabolisme', style: AppTypography.h3),
                const SizedBox(height: 12),
                _MetabolismCard(user: user),
                const SizedBox(height: 16),
                const NutritionInfoWidget(),
                const SizedBox(height: 32),

                // Logout
                SecondaryButton(
                  label: 'Se déconnecter',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Se déconnecter?', style: AppTypography.h3),
                        content: Text('Tu devras te reconnecter.', style: AppTypography.body),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                            child: const Text('Déconnecter'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : '?',
                style: AppTypography.h1.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: AppTypography.h3.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(user.email, style: AppTypography.caption.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  '${user.age} ans  •  ${user.poidsKg}kg  •  ${user.tailleCm}cm',
                  style: AppTypography.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionTargetsCard extends StatelessWidget {
  final NutritionTargets targets;

  const _NutritionTargetsCard({required this.targets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _TargetRow('Calories/jour', '${targets.calories.toInt()} kcal', AppColors.primary),
          _TargetRow('Protéines', '${targets.proteinG.toStringAsFixed(0)} g', AppColors.chartProtein),
          _TargetRow('Glucides', '${targets.carbsG.toStringAsFixed(0)} g', AppColors.chartCarbs),
          _TargetRow('Lipides', '${targets.fatsG.toStringAsFixed(0)} g', AppColors.chartFats),
          _TargetRow('Fibres (min)', '${targets.fiberMin.toStringAsFixed(0)} g', AppColors.chartFiber),
          _TargetRow('Sucres (max)', '${targets.sugarMax.toStringAsFixed(0)} g', AppColors.accent),
          _TargetRow('Sodium (max)', '${targets.sodiumMax.toStringAsFixed(0)} mg', AppColors.textSecondary, isLast: true),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _TargetRow(this.label, this.value, this.color, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: AppTypography.body)),
              Text(value, style: AppTypography.bodyMedium.copyWith(color: color)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

class _MetabolismCard extends StatelessWidget {
  final UserProfile user;

  const _MetabolismCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final bmr = NutritionCalculator.calculateBMR(user);
    final tdee = NutritionCalculator.calculateTDEE(user);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BMR (base)', style: AppTypography.caption),
                  Text('${bmr.toInt()} kcal', style: AppTypography.h3),
                ],
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TDEE (activité)', style: AppTypography.caption),
                  Text('${tdee.toInt()} kcal', style: AppTypography.h3.copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'IMC: ${user.bmi.toStringAsFixed(1)} (${user.bmiCategory})',
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
