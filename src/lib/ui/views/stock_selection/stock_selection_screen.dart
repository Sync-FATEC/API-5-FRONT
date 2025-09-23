import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/views/stock/create_stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../widgets/custom_card.dart'; // Importe o widget que criamos
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
    // Garante que o provider seja chamado após o build da tela
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
    final userProvider = Provider.of<UserProvider>(context);
    print('DEBUG: User Role = ${userProvider.apiUserData?.role}');
    final bool isAdmin = (userProvider.apiUserData?.role?.toLowerCase() ?? '') == 'admin';
    return Scaffold(
      body: Stack( // <-- MUDANÇA 1: Usando Stack para sobrepor os widgets
        children: [
          // Camada de baixo: O Header
          const Header(title: "ESCOLHA O ESTOQUE QUE \nDESEJA GERENCIAR"),

          // Camada de cima: A lista de cards
          Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              final stocks = stockProvider.activeStocks;

              // Usando ListView.builder para melhor performance
              return Padding(
                // <-- MUDANÇA 2: Padding para posicionar a lista
                padding: const EdgeInsets.only(top: 180.0), // Ajuste este valor para subir/descer a lista
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    return Padding(
                      // Adiciona um espaçamento inferior entre os cards
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CustomCard(
                        iconData: _getIconForStock(stock.name),
                        title: stock.name,
                        subtitle: stock.location,
                        onTap: () => _navigateToStock(context, stock),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
            // ADICIONADO: FloatingActionButton que só aparece para admins
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateStock(context),
              backgroundColor: AppColors.bluePrimary,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
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

    void _navigateToCreateStock(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateStockScreen(),
      ),
    );

    // Se o estoque foi criado com sucesso, recarregar a lista
    if (result == true) {
      _loadStocks();
    }
  }
}