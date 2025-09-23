import 'package:api2025/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/stock_option_card.dart'; // Importe o widget que criamos
import '../../widgets/background_header.dart'; // Importe o widget Header padrão

class StockSelectionScreen extends StatefulWidget {
  const StockSelectionScreen({super.key});

  @override
  State<StockSelectionScreen> createState() => _StockSelectionScreenState();
}

class _StockSelectionScreenState extends State<StockSelectionScreen> {
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
    final userId =
        userProvider.apiUserData?.id ?? '4ba9e4c7-c6ba-4f0e-af65-bd6992bc3c2f';
    stockProvider.loadStocks(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header padrão com forma curvada
          const Header(title: 'ESCOLHA O ESTOQUE QUE\nDESEJA GERENCIAR'),
          // Conteúdo da tela
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120), // Espaçamento para o header
                  // Card branco com as opções
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Consumer<StockProvider>(
                      builder: (context, stockProvider, child) {
                        if (stockProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text('Carregando estoques...'),
                              ],
                            ),
                          );
                        }

                        if (stockProvider.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                              ],
                            ),
                          );
                        }

                        final stocks = stockProvider.activeStocks;

                        if (stocks.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Renderizar cards dinamicamente dos estoques da API
                            ...stocks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stock = entry.value;
                              final isLast = index == stocks.length - 1;

                              return Column(
                                children: [
                                  StockOptionCard(
                                    iconData: _getIconForStock(stock.name),
                                    title: stock.name,
                                    subtitle: stock.location,
                                    iconBackgroundColor: AppColors.bluePrimary,
                                    onTap: () {
                                      _navigateToStock(context, stock);
                                    },
                                  ),
                                  if (!isLast)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Divider(
                                        color: Colors.grey[300],
                                        height: 1,
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStock(String stockName) {
    final name = stockName.toLowerCase();
    if (name.contains('farmacia') || name.contains('farmácia')) {
      return Icons.medical_services_outlined;
    } else if (name.contains('almoxarifado')) {
      return Icons.inventory_2_outlined;
    } else {
      return Icons.store_outlined; // Ícone genérico
    }
  }

  void _navigateToStock(BuildContext context, stockData) {
    // Implementar navegação para a tela específica do estoque
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando para ${stockData.name}'),
        backgroundColor: const Color(0xFF2979FF),
      ),
    );
    print('${stockData.name} selecionado - ID: ${stockData.id}');
  }
}
