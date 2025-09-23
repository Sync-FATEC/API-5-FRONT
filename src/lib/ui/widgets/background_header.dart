import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  // 1. Torne as propriedades nulas (adicionando '?')
  final String? title;
  final String? subtitle;
  final int? sizeHeader;

  // 2. Remova 'required' do construtor
  const Header({super.key, this.title, this.subtitle, this.sizeHeader});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: sizeHeader?.toDouble() ?? 300,
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.bluePrimary),
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
      ),
    );
  }
}

// Classe para criar a forma curvada do cabeçalho
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75); // Diminuído de 0.85 para 0.75
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30, // Aumentado de size.height para size.height + 30
      size.width,
      size.height * 0.75, // Diminuído de 0.85 para 0.75
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
