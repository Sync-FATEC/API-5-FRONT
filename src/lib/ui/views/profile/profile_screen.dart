// lib/ui/views/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Perfil do Usuário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.bluePrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final apiData = userProvider.apiUserData;
          final firebaseUser = userProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card com informações do Firebase
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                              'Dados do Firebase',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('UID:', firebaseUser?.uid ?? 'N/A'),
                        _buildInfoRow('Email:', firebaseUser?.email ?? 'N/A'),
                        _buildInfoRow('Nome:', firebaseUser?.displayName ?? 'N/A'),
                        _buildInfoRow('Verificado:', firebaseUser?.emailVerified == true ? 'Sim' : 'Não'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card com informações da API
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                              'Dados da API',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (apiData != null) ...[
                          _buildInfoRow('ID:', apiData.id),
                          _buildInfoRow('Email:', apiData.email),
                          _buildInfoRow('Nome:', apiData.name),
                          _buildInfoRow('Função:', apiData.role),
                          _buildInfoRow('Válido até:', _formatDate(apiData.validUntil)),
                          _buildInfoRow('Criado em:', _formatDate(apiData.createdAt)),
                          _buildInfoRow('Ativo:', apiData.isActive ? 'Sim' : 'Não'),
                        ] else ...[
                          const Text(
                            'Dados da API não disponíveis',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botão de logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await userProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
}