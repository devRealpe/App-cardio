// lib/presentation/pages/formulario/widgets/form_header.dart
import 'package:flutter/material.dart';
import '../../../theme/medical_colors.dart';

class FormHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onInfoPressed;

  const FormHeader({
    super.key,
    required this.onInfoPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MedicalColors.primaryBlue,
            MedicalColors.primaryBlue.withAlpha((0.85 * 255).toInt()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.primaryBlue.withAlpha((0.3 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.3 * 255).toInt()),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Etiquetado Cardíaco',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.15 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: onInfoPressed,
                      tooltip: 'Información',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
