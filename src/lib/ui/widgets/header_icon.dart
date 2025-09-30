import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HeaderIcon extends StatelessWidget {
  // 1. Torne as propriedades nulas (adicionando '?')
  final String? title;
  final String? subtitle;
  final int? sizeHeader;

  // 2. Remova 'required' do construtor
  const HeaderIcon({super.key, this.title, this.subtitle, this.sizeHeader});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Container(
        height: sizeHeader?.toDouble() ?? 300,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Layout similar ao login_form.dart com imagens nas laterais
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/LOGO1.png', height: 70),
                  Expanded(
                    child: Column(
                      children: [
                        if (title != null && title!.isNotEmpty)
                          Text(
                            title!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Image.asset('assets/LOGO2.png', height: 70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
