// lib/ui/views/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/stock_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/background_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStocks();
    });
  }

  void _loadStocks() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    
    // Usar o ID do usuário da API ou um ID fixo para teste
    final userId = userProvider.apiUserData?.id ?? '4ba9e4c7-c6ba-4f0e-af65-bd6992bc3c2f';
    stockProvider.loadStocks(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Widget 1: O Header Azul
            const Header(
              title: "ESCOLHA O ESTOQUE QUE",
              subtitle: "DESEJA GERENCIAR",
            ),

            // Widget 2: O Card de Seleção de Estoque
            Padding(
              padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Consumer<StockProvider>(
                  builder: (context, stockProvider, child) {
                    if (stockProvider.isLoading) {
                      return const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 50),
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Carregando estoques...'),
                          SizedBox(height: 50),
                        ],
                      );
                    }

                    if (stockProvider.errorMessage != null) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar estoques',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stockProvider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadStocks,
                            child: const Text('Tentar novamente'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }

                    final stocks = stockProvider.activeStocks;
                    
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Renderizar cards dinamicamente
                        ...stocks.map((stock) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildStockCard(
                            context,
                            title: stock.name,
                            subtitle: stock.location,
                            icon: _getIconForStock(stock.name),
                            onTap: () {
                              _navigateToStock(context, stock);
                            },
                          ),
                        )).toList(),
                        
                        if (stocks.isEmpty)
                          const Column(
                            children: [
                              Icon(
                                Icons.inventory_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum estoque disponível',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bluePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Seta
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStock(String stockName) {
    final name = stockName.toLowerCase();
    if (name.contains('farmacia') || name.contains('farmácia')) {
      return Icons.medical_services;
    } else if (name.contains('almoxarifado')) {
      return Icons.inventory_2;
    } else {
      return Icons.store; // Ícone genérico
    }
  }

  void _navigateToStock(BuildContext context, stockData) {
    // Implementar navegação para a tela específica do estoque
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando para ${stockData.name}'),
        backgroundColor: AppColors.bluePrimary,
      ),
    );
  }
}