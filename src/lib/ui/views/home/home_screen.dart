// lib/ui/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/header_icon.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../widgets/custom_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              final selectedStock = stockProvider.selectedStock;

              if (selectedStock == null) {
                return const HeaderIcon(title: 'NENHUM ESTOQUE SELECIONADO');
              }

              return HeaderIcon(
                title: selectedStock.name.toUpperCase(),
                subtitle: selectedStock.location,
              );
            },
          ),
          // Botão de voltar
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/stock-selection');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.bluePrimary,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Voltar',
                      style: TextStyle(
                        color: AppColors.bluePrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Consumer2<UserProvider, StockProvider>(
              builder: (context, userProvider, stockProvider, child) {
                final user = userProvider.apiUserData;

                if (user == null) {
                  return const Center(child: Text('No user data available.'));
                }

                return Column(
                  children: [
                    // Cards principais
                    CustomCard(
                      iconData: Icons.add_circle_outline,
                      title: 'Cadastro novo produto',
                      subtitle:
                          'Adicione novos produtos no\nseu estoque do ${stockProvider.selectedStock?.name ?? 'estoque'}',
                      onTap: () {
                        Navigator.pushNamed(context, '/merchandise-menu');
                        print('Navegando para cadastro de produto');
                      },
                    ),
                    CustomCard(
                      iconData: Icons.inventory_2_outlined,
                      title: 'Controle do Estoque',
                      subtitle:
                          'Adicione novos produtos no\nseu estoque do ${stockProvider.selectedStock?.name ?? 'estoque'}',
                      onTap: () {
                        // TODO: Navegar para tela de controle de estoque
                        print('Navegando para controle de estoque');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
    );
  }
}
