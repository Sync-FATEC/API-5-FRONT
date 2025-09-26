// lib/ui/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../widgets/header_icon.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../widgets/custom_card.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

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
                      iconData: Icons.person_add_alt_1_outlined,
                      title: 'Cadastro de usuários',
                      subtitle:
                          'Realize novos pedidos',
                      onTap: () {
                        // TODO: Navegar para tela de cadastro de produto
                        print('Navegando para cadastro de produto');
                      },
                    ),
                    CustomCard(
                      iconData: Icons.person_sharp,
                      title: 'Gerenciar usuários',
                      subtitle:
                          'Faça a listagem de pedidos',
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
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 4),
    );
  }
}
