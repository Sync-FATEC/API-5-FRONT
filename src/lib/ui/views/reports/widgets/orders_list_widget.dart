import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/order_model.dart';

class OrdersListWidget extends StatefulWidget {
  final List<Order>? orders;

  const OrdersListWidget({super.key, this.orders});

  @override
  State<OrdersListWidget> createState() => _OrdersListWidgetState();
}

class _OrdersListWidgetState extends State<OrdersListWidget> {
  String sortField = 'creationDate';
  bool sortAscending = false;
  int currentPage = 1;
  static const int itemsPerPage = 10;

  List<Order> get sortedOrders {
    if (widget.orders == null) return [];

    final orders = List<Order>.from(widget.orders!);

    orders.sort((a, b) {
      int comparison = 0;

      switch (sortField) {
        case 'creationDate':
          comparison = _parseDate(
            a.creationDate,
          ).compareTo(_parseDate(b.creationDate));
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'sectionName':
          comparison = a.sectionName.compareTo(b.sectionName);
          break;
        case 'withdrawalDate':
          final aDate = a.withdrawalDate != null
              ? _parseDate(a.withdrawalDate!)
              : DateTime(1900);
          final bDate = b.withdrawalDate != null
              ? _parseDate(b.withdrawalDate!)
              : DateTime(1900);
          comparison = aDate.compareTo(bDate);
          break;
      }

      return sortAscending ? comparison : -comparison;
    });

    return orders;
  }

  List<Order> get paginatedOrders {
    final orders = sortedOrders;
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, orders.length);
    return orders.sublist(startIndex, endIndex);
  }

  int get totalPages => (sortedOrders.length / itemsPerPage).ceil();

  void _handleSort(String field) {
    setState(() {
      if (sortField == field) {
        sortAscending = !sortAscending;
      } else {
        sortField = field;
        sortAscending = true;
      }
      currentPage = 1; // Reset para primeira página ao ordenar
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finalizado':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'completed':
      case 'finalizado':
        return 'Finalizado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  DateTime _parseDate(String dateString) {
    // Se a string da data não tem informação de fuso horário,
    // trata como data local para evitar conversões de timezone
    if (dateString.contains('T') ||
        dateString.contains('Z') ||
        dateString.contains('+')) {
      // Data com informação de timezone - usar parse normal
      return DateTime.parse(dateString);
    } else {
      // Data apenas com ano-mês-dia - tratar como local
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]), // ano
          int.parse(parts[1]), // mês
          int.parse(parts[2]), // dia
        );
      } else {
        return DateTime.parse(dateString);
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = _parseDate(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  Widget _buildSortButton(String field, String title) {
    return InkWell(
      onTap: () => _handleSort(field),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 4),
          if (sortField == field)
            Icon(
              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: Colors.blue.shade600,
            )
          else
            Icon(Icons.sort, size: 12, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pedidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              if (widget.orders != null && widget.orders!.isNotEmpty)
                Text(
                  ' (${widget.orders!.length} total)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.orders == null || widget.orders!.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Text(
                'Nenhum pedido encontrado para o período selecionado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            )
          else
            Column(
              children: [
                // Tabela responsiva
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Layout para mobile - cards
                      return Column(
                        children: paginatedOrders
                            .map((order) => _buildMobileOrderCard(order))
                            .toList(),
                      );
                    } else {
                      // Layout para desktop - tabela
                      return _buildDesktopTable();
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Paginação
                if (totalPages > 1) _buildPagination(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMobileOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.creationDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Seção: ${order.sectionName}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Itens: ${order.orderItems.length}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (order.withdrawalDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Retirada: ${_formatDate(order.withdrawalDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(2),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildSortButton('creationDate', 'Data'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildSortButton('status', 'Status'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildSortButton('sectionName', 'Seção'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Itens',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildSortButton('withdrawalDate', 'Retirada'),
            ),
          ],
        ),
        // Dados
        ...paginatedOrders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;
          return TableRow(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.white : Colors.grey.shade50,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _formatDate(order.creationDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  order.sectionName,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${order.orderItems.length} item(s)',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _formatDate(order.withdrawalDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: order.withdrawalDate != null
                        ? Colors.black
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () => setState(() => currentPage--)
              : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: 20,
        ),
        Text(
          '$currentPage de $totalPages',
          style: const TextStyle(fontSize: 12),
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => setState(() => currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right),
          iconSize: 20,
        ),
      ],
    );
  }
}
