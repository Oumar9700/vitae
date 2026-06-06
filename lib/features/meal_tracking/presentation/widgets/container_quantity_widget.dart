import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

/// Section 4 — Récipients visuels avec compteur.
/// "J'ai pris 1 bol + 2 cuillères" → calcul automatique en grammes.
class ContainerQuantityWidget extends StatefulWidget {
  final void Function(double totalGrams) onChanged;

  const ContainerQuantityWidget({super.key, required this.onChanged});

  @override
  State<ContainerQuantityWidget> createState() => _ContainerQuantityWidgetState();
}

class _ContainerQuantityWidgetState extends State<ContainerQuantityWidget> {
  static const Map<String, _Container> _containers = {
    'bol': _Container('Bol', 250, '🥣'),
    'assiette': _Container('Assiette', 300, '🍽️'),
    'verre': _Container('Verre', 200, '🥛'),
    'tasse': _Container('Tasse', 150, '☕'),
    'cuillère à soupe': _Container('c. à soupe', 15, '🥄'),
    'cuillère à café': _Container('c. à café', 5, '🫙'),
    'poignée': _Container('Poignée', 30, '✊'),
    'tranche': _Container('Tranche', 28, '🔪'),
  };

  final Map<String, int> _counts = {};

  double get _total {
    double t = 0;
    _counts.forEach((k, count) => t += (_containers[k]?.grams ?? 0) * count);
    return t;
  }

  void _update(String key, int delta) {
    setState(() {
      final current = _counts[key] ?? 0;
      final next = (current + delta).clamp(0, 20);
      if (next == 0) {
        _counts.remove(key);
      } else {
        _counts[key] = next;
      }
    });
    widget.onChanged(_total);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avec quel récipient ?', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _containers.entries.map((e) {
            final count = _counts[e.key] ?? 0;
            final isActive = count > 0;
            return GestureDetector(
              onTap: () => _update(e.key, 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryPale : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.value.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(e.value.label, style: AppTypography.caption.copyWith(color: isActive ? AppColors.primary : AppColors.textSecondary)),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Text(
                        '×$count',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Compteurs détaillés pour les récipients sélectionnés
        if (_counts.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._counts.entries.map((e) {
            final c = _containers[e.key]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text('${c.emoji} ${c.label}', style: AppTypography.body),
                  const Spacer(),
                  _CounterButton(
                    icon: Icons.remove,
                    onTap: () => _update(e.key, -1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${e.value}', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary)),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onTap: () => _update(e.key, 1),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(e.value * c.grams).toInt()} g',
                    style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Total : ', style: AppTypography.label),
              Text(
                '${_total.toInt()} g',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryPale,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _Container {
  final String label;
  final double grams;
  final String emoji;
  const _Container(this.label, this.grams, this.emoji);
}
