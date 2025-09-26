// lib/ui/views/stock/stock_selection_screen.dart

import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/views/stock/widgets/create_stock_screen.dart';
import 'package:api2025/ui/views/section/section_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background_header.dart';
import '../../widgets/add_floating_button.dart';

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

    final userId =
        userProvider.apiUserData?.id ?? '4ba9e4c7-c6ba-4f0e-af65-bd6992bc3c2f';
    stockProvider.loadStocks(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isAdmin =
        (userProvider.apiUserData?.role?.toLowerCase() ?? '') == 'admin';

    return Scaffold(
      body: Stack(
        children: [
          Header(
            title: "ESCOLHA O ESTOQUE QUE \nDESEJA GERENCIAR",
          ),
          Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              final stocks = stockProvider.activeStocks;
              return Padding(
                padding: const EdgeInsets.only(top: 180.0),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CustomCard(
                        iconData: _getIconForStock(stock.name),
                        title: stock.name,
                        subtitle: stock.location,
                        onTap: () => _navigateToStock(context, stock),
                        onDelete: isAdmin
                            ? () => _deleteStock(context, stock.id)
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnSection",
            onPressed: () => _navigateToSection(context),
            backgroundColor: AppColors.bluePrimary,
            child: const Icon(Icons.business, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // PASSO 2: Substitua o botão antigo pelo novo componente
          AddFloatingButton(
            heroTag: "btnAddStock",
            isVisible: isAdmin, // A visibilidade é controlada aqui
            onPressed: () => _navigateToCreateStock(context),
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
      return Icons.store_outlined;
    }
  }

  void _navigateToStock(BuildContext context, stockData) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    // Selecionar o estoque no provider
    stockProvider.selectStock(stockData);

    // Navegar para a tela home
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToCreateStock(BuildContext context) async {
    final result = await CreateStockModal.show(context);
    if (result == true) {
      _loadStocks();
    }
  }

  void _navigateToSection(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SectionScreen()));
  }

  void _deleteStock(BuildContext context, String stockId) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    try {
      final success = await stockProvider.deleteStock(stockId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estoque excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stockProvider.errorMessage ?? 'Erro ao excluir estoque',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir estoque: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
