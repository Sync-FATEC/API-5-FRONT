import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function? onDelete;
  final Function? onEdit;
  final Function? onChangeStatus;
  final Function? onFinalize;
  final bool showArrow;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
    this.onChangeStatus,
    this.onFinalize,
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

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opções',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (onEdit != null)
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Excluir'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Pedido ${order.id.substring(0, 8)}?'),
          content: const Text('Tem certeza que deseja excluir este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) {
                  onDelete!();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Criar descrição com todos os itens do pedido
    String itemDescription;
    if (order.orderItems.isEmpty) {
      itemDescription = 'Sem itens';
    } else if (order.orderItems.length == 1) {
      final item = order.orderItems.first;
      itemDescription = '${item.quantity}x ${item.merchandiseName}';
    } else {
      // Múltiplos itens - exibir todos
      itemDescription = order.orderItems
          .map((item) => '${item.quantity}x ${item.merchandiseName}')
          .join('\n');
    }

    // Formatar data
    final formattedDate = _formatDate(order.creationDate);

    return GestureDetector(
      onTap: onTap,
      onLongPress: (order.status == 'PENDING' && (onDelete != null || onEdit != null || onChangeStatus != null))
          ? () {
              _showOptionsBottomSheet(context);
            }
          : onLongPress,
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
                    maxLines: null, // Permite múltiplas linhas
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
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: order.status == 'PENDING' && onFinalize != null ? 8.0 : 16.0,
              ),
              child: Text(
                'DATA DO PEDIDO: $formattedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            // Botão Finalizar Pedido (apenas para pedidos em aberto)
            if (order.status == 'PENDING' && onFinalize != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onFinalize!(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Finalizar Pedido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
