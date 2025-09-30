// lib/ui/views/users/users_screen.dart

import 'package:api2025/ui/widgets/custom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../widgets/header_icon.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../widgets/custom_card.dart';
import 'users_management_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

    void _showUserRegistrationModal(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Controllers para os campos do formulário
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final List<Map<String, String>> _roles = [
      {'value': 'SOLDADO', 'label': 'Soldado'},
      {'value': 'SUPERVISOR', 'label': 'Supervisor'},
      {'value': 'ADMIN', 'label': 'Administrador'},
    ];

    CustomModal.show(
      context: context,
      title: 'Cadastro de Usuário',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomModalTextField(
              label: 'Nome',
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomModalTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Função',
                border: OutlineInputBorder(),
              ),
              value: null,
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role['value'],
                  child: Text(role['label']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  roleController.text = newValue;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomModalButton(
              text: 'Cadastrar',
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await userProvider.createUser(
                      nameController.text,
                      emailController.text,
                      roleController.text,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuário cadastrado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao cadastrar usuário: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
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
            padding: const EdgeInsets.only(top: 140.0),
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
