// lib/ui/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card com informações do Firebase
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: AppColors.bluePrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Informações do Firebase',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildUserInfo('ID do Usuário:', userProvider.userId),
                        const SizedBox(height: 8),
                        _buildUserInfo('E-mail:', userProvider.userEmail),
                        const SizedBox(height: 8),
                        _buildUserInfo(
                          'Nome de Exibição:', 
                          userProvider.userDisplayName.isEmpty 
                              ? 'Não definido' 
                              : userProvider.userDisplayName,
                        ),
                        const SizedBox(height: 8),
                        _buildUserInfo(
                          'Status:', 
                          userProvider.isLoggedIn ? 'Logado' : 'Não logado',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Card com informações da API
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.api,
                              color: AppColors.bluePrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Informações da API',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (userProvider.apiUserData != null) ...[
                          _buildUserInfo('ID:', userProvider.apiUserData!.id),
                          const SizedBox(height: 8),
                          _buildUserInfo('E-mail:', userProvider.apiUserData!.email),
                          const SizedBox(height: 8),
                          _buildUserInfo('Nome:', userProvider.apiUserData!.name),
                          const SizedBox(height: 8),
                          _buildUserInfo('Função:', userProvider.apiUserData!.role),
                          const SizedBox(height: 8),
                          _buildUserInfo('Válido até:', _formatDate(userProvider.apiUserData!.validUntil)),
                          const SizedBox(height: 8),
                          _buildUserInfo('Criado em:', _formatDate(userProvider.apiUserData!.createdAt)),
                          const SizedBox(height: 8),
                          _buildUserInfo('Ativo:', userProvider.apiUserData!.isActive ? 'Sim' : 'Não'),
                        ] else ...[
                          const Text(
                            'Dados da API não disponíveis',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Card com ações
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ações Disponíveis',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              userProvider.updateUserData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dados do usuário atualizados!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.bluePrimary,
                            ),
                            child: const Text(
                              'Atualizar Dados do Usuário',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showLogoutDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Fazer Logout',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: TextStyle(
              color: value.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();
                
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}