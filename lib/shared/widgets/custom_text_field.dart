import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class VitaeTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int? maxLines;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const VitaeTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<VitaeTextField> createState() => _VitaeTextFieldState();
}

class _VitaeTextFieldState extends State<VitaeTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText ? _obscure : false,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          onEditingComplete: widget.onEditingComplete,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          focusNode: widget.focusNode,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength; // 0-5

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.transparent,
      AppColors.error,
      AppColors.error,
      AppColors.accent,
      AppColors.accent,
      AppColors.primary,
    ];
    final labels = ['', 'Très faible', 'Faible', 'Moyen', 'Bon', 'Fort'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: index < strength ? colors[strength] : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (strength > 0) ...[
          const SizedBox(height: 4),
          Text(
            labels[strength],
            style: AppTypography.caption.copyWith(
              color: colors[strength],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
