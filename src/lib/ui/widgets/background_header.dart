import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  // Propriedades do componente
  final String? title;
  final String? subtitle;
  final int? sizeHeader;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const Header({
    super.key, 
    this.title, 
    this.subtitle, 
    this.sizeHeader,
    this.onBackPressed,
    this.showBackButton = false,
  });

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
              // Botão de voltar e título
              if (showBackButton || (title != null && title!.isNotEmpty))
                Row(
                  children: [
                    if (showBackButton)
                      GestureDetector(
                        onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    if (showBackButton && title != null && title!.isNotEmpty)
                      const SizedBox(width: 10),
                    if (title != null && title!.isNotEmpty)
                      Expanded(
                        child: GestureDetector(
                          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                          child: Text(
                            title!,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

              if (subtitle != null && subtitle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
