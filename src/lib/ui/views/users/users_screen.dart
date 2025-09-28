// lib/ui/views/users/users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../widgets/header_icon.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../widgets/custom_card.dart';
import '../../modals/user_registration_modal.dart';
import 'users_management_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  void _showUserRegistrationModal(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    UserRegistrationHelper.showModal(
      context: context,
      onRegister: (String name, String email, String role) async {
        await userProvider.createUser(name, email, role);
      },
    );
  }

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
                      subtitle: 'Cadastre novos usuários no sistema',
                      onTap: () {
                        _showUserRegistrationModal(context);
                      },
                    ),
                    CustomCard(
                      iconData: Icons.person_sharp,
                      title: 'Gerenciar usuários',
                      subtitle: 'Visualize e gerencie usuários cadastrados',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsersManagementScreen(),
                          ),
                        );
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
