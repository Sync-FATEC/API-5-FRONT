import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/widgets/bottom_nav_bar_widget.dart';
import 'package:api2025/data/models/order_model.dart';
import 'package:api2025/core/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
    orderProvider.loadOrders();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Em Aberto';
      case 'COMPLETED':
        return 'Finalizado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(title: "VOLTAR",
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                // Campo de busca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildFilterButton(
                            filter, 
                            isSelected,
                            () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
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
                      List<Order> filteredOrders = orderProvider.getFilteredOrders(_selectedFilter);
                      // Aplicar busca
                      if (_searchQuery.isNotEmpty) {
                        filteredOrders = orderProvider.searchOrders(_searchQuery);
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildOrderCard(order),
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
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 1),
    );
  }

  Widget _buildOrderCard(Order order) {
    // Obter o primeiro item do pedido para exibição
    final firstItem = order.orderItems.isNotEmpty ? order.orderItems.first : null;
    final itemDescription = firstItem != null 
        ? '${firstItem.quantity}x ${firstItem.merchandiseName}'
        : 'Sem itens';
    
    // Formatar data
    final formattedDate = _formatDate(order.creationDate);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // ID do pedido
                Text(
                  order.id.substring(0, 8),
                  style: const TextStyle(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                // Seta para detalhes
                GestureDetector(
                  onTap: () {
                    // Navegação para detalhes do pedido
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.sectionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itemDescription,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: order.status == 'COMPLETED' ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: order.status == 'COMPLETED' ? Colors.green[800] : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Linha divisória
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1),
          ),
          // Data do pedido
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text(
              'DATA DO PEDIDO: $formattedDate',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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
}
