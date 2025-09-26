// lib/ui/widgets/add_floating_button.dart

import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';

class AddFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;
  final String heroTag;

  const AddFloatingButton({
    super.key,
    required this.onPressed,
    this.isVisible = true,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    // Só exibe o botão se isVisible for verdadeiro
    return isVisible
        ? FloatingActionButton(
            heroTag: heroTag,
            onPressed: onPressed,
            backgroundColor: AppColors.bluePrimary,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        // Caso contrário, retorna um widget vazio que não ocupa espaço
        : const SizedBox.shrink();
  }
}