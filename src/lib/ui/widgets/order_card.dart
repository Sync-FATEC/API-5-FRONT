import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final bool showArrow;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showArrow = true,
  });

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

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green[100]!;
      default:
        return Colors.orange[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green[800]!;
      default:
        return Colors.orange[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obter o primeiro item do pedido para exibição
    final firstItem = order.orderItems.isNotEmpty
        ? order.orderItems.first
        : null;
    final itemDescription = firstItem != null
        ? '${firstItem.quantity}x ${firstItem.merchandiseName}'
        : 'Sem itens';

    // Formatar data
    final formattedDate = _formatDate(order.creationDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  // Seta para detalhes (condicional)
                  if (showArrow)
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
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
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBackgroundColor(order.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        color: _getStatusTextColor(order.status),
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
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
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
      ),
    );
  }
}
