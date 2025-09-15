// lib/examples/api_usage_example.dart
// Este arquivo mostra exemplos de como usar os dados da API após o login

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_provider.dart';

class ApiUsageExample extends StatelessWidget {
  const ApiUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo de Uso da API'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Verificar se o usuário está logado
          if (!userProvider.isLoggedIn) {
            return const Center(
              child: Text('Usuário não está logado'),
            );
          }

          // Acessar dados do Firebase
          final firebaseUser = userProvider.currentUser;
          
          // Acessar dados da API
          final apiUserData = userProvider.apiUserData;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exemplos de como acessar os dados:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Exemplo 1: Dados básicos do usuário
                _buildExampleSection(
                  'Dados Básicos do Usuário',
                  [
                    'Email: ${userProvider.userEmail}',
                    'Nome: ${userProvider.userDisplayName}',
                    'ID Firebase: ${userProvider.userId}',
                  ],
                ),
                
                // Exemplo 2: Dados específicos da API
                if (apiUserData != null)
                  _buildExampleSection(
                    'Dados da API',
                    [
                      'ID da API: ${apiUserData.id}',
                      'Função: ${userProvider.userRole}',
                      'Status: ${userProvider.isUserActive ? "Ativo" : "Inativo"}',
                      'Válido até: ${userProvider.userValidUntil}',
                    ],
                  ),
                
                // Exemplo 3: Verificações condicionais
                _buildExampleSection(
                  'Verificações Condicionais',
                  [
                    'Usuário logado: ${userProvider.isLoggedIn ? "Sim" : "Não"}',
                    'Dados da API carregados: ${apiUserData != null ? "Sim" : "Não"}',
                    'Usuário ativo: ${userProvider.isUserActive ? "Sim" : "Não"}',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Exemplo de uso em código
                const Text(
                  'Exemplo de código:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '''// Acessar dados do usuário em qualquer widget:
final userProvider = Provider.of<UserProvider>(context);

// Verificar se usuário está logado
if (userProvider.isLoggedIn) {
  // Acessar dados básicos
  String email = userProvider.userEmail;
  String nome = userProvider.userDisplayName;
  
  // Acessar dados da API
  if (userProvider.apiUserData != null) {
    String funcao = userProvider.userRole;
    bool ativo = userProvider.isUserActive;
  }
}''',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
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

  Widget _buildExampleSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text('• $item'),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Exemplo de como usar em um ViewModel personalizado
class ExampleViewModel extends ChangeNotifier {
  final BuildContext context;
  
  ExampleViewModel(this.context);
  
  // Exemplo de método que usa os dados da API
  void checkUserPermissions() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Verificar se usuário está logado
    if (!userProvider.isLoggedIn) {
      print('Usuário não está logado');
      return;
    }
    
    // Verificar dados da API
    final apiData = userProvider.apiUserData;
    if (apiData == null) {
      print('Dados da API não disponíveis');
      return;
    }
    
    // Verificar permissões baseadas na função
    switch (apiData.role.toUpperCase()) {
      case 'ADMIN':
        print('Usuário tem permissões de administrador');
        break;
      case 'SOLDADO':
        print('Usuário tem permissões de soldado');
        break;
      default:
        print('Função não reconhecida: ${apiData.role}');
    }
    
    // Verificar se usuário está ativo
    if (!apiData.isActive) {
      print('Usuário está inativo');
      return;
    }
    
    // Verificar validade
    try {
      final validUntil = DateTime.parse(apiData.validUntil);
      if (validUntil.isBefore(DateTime.now())) {
        print('Acesso do usuário expirou');
        return;
      }
    } catch (e) {
      print('Erro ao verificar validade: $e');
    }
    
    print('Usuário tem todas as permissões necessárias');
  }
}