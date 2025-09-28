// lib/ui/views/orders/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/stock_provider.dart';
import '../../widgets/header_icon.dart';
import '../../widgets/bottom_nav_bar_widget.dart';
import '../../widgets/custom_card.dart';
import 'widgets/create_order_modal.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
                      iconData: Icons.add_circle_outline,
                      title: 'Cadastro de pedidos',
                      subtitle: 'Realize novos pedidos',
                      onTap: () => _openCreateOrderModal(context),
                    ),
                    CustomCard(
                      iconData: Icons.inventory_2_outlined,
                      title: 'Listagem de pedidos',
                      subtitle: 'Faça a listagem de pedidos',
                      onTap: () {
                        _navigateTo(context, '/orders-list');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 1),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Future<void> _openCreateOrderModal(BuildContext context) async {
    final result = await CreateOrderModal.show(context);
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
