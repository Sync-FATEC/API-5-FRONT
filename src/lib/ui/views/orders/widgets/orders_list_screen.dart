import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/widgets/bottom_nav_bar_widget.dart';
import 'package:api2025/ui/widgets/order_card.dart';
import 'package:api2025/data/models/order_model.dart';
import 'package:api2025/core/providers/order_provider.dart';
import 'package:api2025/core/providers/stock_provider.dart';
import 'package:provider/provider.dart';
import 'create_order_modal.dart';
import 'change_status_modal.dart';

class OrdersListScreen extends StatefulWidget {
  final String title;
  final List<String> filterOptions;

  const OrdersListScreen({
    super.key,
    this.title = "LISTAGEM DE PEDIDOS",
    this.filterOptions = const ['TODOS', 'EM ABERTO', 'FINALIZADOS'],
  });

  @override
  State<OrdersListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrdersListScreen> {
  String _selectedFilter = 'TODOS';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Garante que o provider seja chamado após o build da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    print("Método _loadOrders chamado");
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final selectedStock = stockProvider.selectedStock;
    
    if (selectedStock != null) {
      print("Carregando pedidos para o stock: ${selectedStock.id}");
      orderProvider.loadOrders(stockId: selectedStock.id);
    } else {
      print("Nenhum stock selecionado, carregando todos os pedidos");
      orderProvider.loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(
            title: "VOLTAR",
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
            sizeHeader: 450,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                // Campo de busca
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                // Filtros
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildFilterButton(filter, isSelected, () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Lista de pedidos
                Expanded(
                  child: Consumer<OrderProvider>(
                    builder: (context, orderProvider, child) {
                      if (orderProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bluePrimary,
                          ),
                        );
                      }

                      if (orderProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Erro ao carregar pedidos',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadOrders,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bluePrimary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filtrar pedidos
                      List<Order> filteredOrders = orderProvider
                          .getFilteredOrders(_selectedFilter);
                      // Aplicar busca
                      if (_searchQuery.isNotEmpty) {
                        filteredOrders = orderProvider.searchOrders(
                          _searchQuery,
                        );
                      }

                      if (filteredOrders.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum pedido encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: OrderCard(
                              order: order,
                              onTap: () {
                                // Navegação para detalhes do pedido
                                // TODO: Implementar navegação para detalhes
                              },
                              onEdit: () => _editOrder(context, order),
                              onDelete: () => _deleteOrder(context, order),
                              onChangeStatus: () => _changeOrderStatus(context, order),
                              onFinalize: () => _finalizeOrder(context, order),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.bluePrimary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.bluePrimary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.bluePrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showOrderOptions(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opções do Pedido',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.bluePrimary),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _editOrder(context, order);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteOrder(BuildContext context, Order order) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final selectedStock = stockProvider.selectedStock;
      
      // Passar o stockId se houver um estoque selecionado
      final success = await orderProvider.deleteOrder(
        order.id, 
        stockId: selectedStock?.id
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Erro ao excluir pedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editOrder(BuildContext context, Order order) async {
    final result = await CreateOrderModal.show(context, orderToEdit: order);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changeOrderStatus(BuildContext context, Order order) async {
    final newStatus = await ChangeStatusModal.show(context, order.status);
    if (newStatus != null && mounted) {
      try {
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        final stockProvider = Provider.of<StockProvider>(context, listen: false);
        final selectedStock = stockProvider.selectedStock;
        
        final success = await orderProvider.updateOrderStatus(
          order.id, 
          newStatus,
          stockId: selectedStock?.id
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status do pedido alterado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(orderProvider.errorMessage ?? 'Erro ao alterar status do pedido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao alterar status do pedido: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _finalizeOrder(BuildContext context, Order order) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final selectedStock = stockProvider.selectedStock;
      
      final success = await orderProvider.updateOrderStatus(
        order.id, 
        'COMPLETED',
        stockId: selectedStock?.id,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido finalizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Erro ao finalizar pedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
