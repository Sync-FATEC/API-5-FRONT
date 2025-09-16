import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  // 1. Torne as propriedades nulas (adicionando '?')
  final String? title;
  final String? subtitle;

  // 2. Remova 'required' do construtor
  const Header({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bluePrimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. Renderize o Texto apenas se a string não for nula nem vazia
            if (title != null && title!.isNotEmpty)
              Text(
                title!, // Usamos '!' para garantir que não é nulo aqui
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!, // Usamos '!' para garantir que não é nulo aqui
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}