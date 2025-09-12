import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
        return Container(
      height: 250, // Altura do container azul
      width: double.infinity, // Ocupa toda a largura
      decoration: BoxDecoration(
        color: AppColors.bluePrimary, // A cor vai aqui dentro
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), // Raio do canto inferior esquerdo
          bottomRight: Radius.circular(20), // Raio do canto inferior direito
        ),
      ), // Um tom de azul escuro
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha o texto à esquerda
          children: const [
            Text(
              "APP",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "CONTROLE DE ESTOQUE",
              style: TextStyle(
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