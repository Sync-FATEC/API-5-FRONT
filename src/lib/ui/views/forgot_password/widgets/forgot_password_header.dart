import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250, // Altura do container azul
      width: double.infinity, // Ocupa toda a largura
      decoration: const BoxDecoration(
        color: AppColors.bluePrimary, // A cor vai aqui dentro
        borderRadius: BorderRadius.only(
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
              "RECUPERAR SENHA",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}