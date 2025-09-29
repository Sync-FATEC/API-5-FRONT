import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/models/merchandise_type_model.dart';
import 'package:api2025/data/enums/merchandise_enums.dart';

class MerchandiseCard extends StatelessWidget {
  final MerchandiseTypeModel merchandise;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function? onDelete;
  final Function? onEdit;
  final bool showArrow;

  const MerchandiseCard({
    super.key,
    required this.merchandise,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
    this.showArrow = true,
  });

  String _getGroupText(MerchandiseGroup? group) {
    if (group == null) return 'Sem Grupo';
    switch (group) {
      case MerchandiseGroup.medical:
        return 'Médico';
      case MerchandiseGroup.almox:
        return 'Almoxarifado';
    }
  }

  Color _getGroupBackgroundColor(MerchandiseGroup? group) {
    if (group == null) return Colors.grey[100]!;
    switch (group) {
      case MerchandiseGroup.medical:
        return Colors.blue[100]!;
      case MerchandiseGroup.almox:
        return Colors.orange[100]!;
    }
  }

  Color _getGroupTextColor(MerchandiseGroup? group) {
    if (group == null) return Colors.grey[800]!;
    switch (group) {
      case MerchandiseGroup.medical:
        return Colors.blue[800]!;
      case MerchandiseGroup.almox:
        return Colors.orange[800]!;
    }
  }

  Color _getStockColor(int currentStock, int minimumStock) {
    if (currentStock <= 0) {
      return Colors.red; // Sem estoque
    } else if (currentStock <= minimumStock) {
      return Colors.orange; // Estoque baixo
    } else {
      return Colors.green; // Estoque ok
    }
  }

  String _getStockStatus(int currentStock, int minimumStock) {
    if (currentStock <= 0) {
      return 'SEM ESTOQUE';
    } else if (currentStock <= minimumStock) {
      return 'ESTOQUE BAIXO';
    } else {
      return 'ESTOQUE OK';
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
          title: Text('Excluir ${merchandise.name}?'),
          content: const Text('Tem certeza que deseja excluir este item de mercadoria?'),
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
    return GestureDetector(
      onTap: onTap,
      onLongPress: (onDelete != null || onEdit != null)
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
                  // Nome do produto
                  Expanded(
                    child: Text(
                      merchandise.name,
                      style: const TextStyle(
                        color: AppColors.bluePrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
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
                  // Número de registro
                  Text(
                    'Registro: ${merchandise.recordNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Unidade de medida
                  Text(
                    'Unidade: ${merchandise.unitOfMeasure}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Grupo da mercadoria
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getGroupBackgroundColor(merchandise.group),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getGroupText(merchandise.group),
                          style: TextStyle(
                            color: _getGroupTextColor(merchandise.group),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (merchandise.controlled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CONTROLADO',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Linha divisória
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1),
            ),
            // Informações de estoque
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTOQUE ATUAL: ${merchandise.quantityTotal}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'ESTOQUE MÍNIMO: ${merchandise.minimumStock}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStockColor(merchandise.quantityTotal, merchandise.minimumStock).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStockStatus(merchandise.quantityTotal, merchandise.minimumStock),
                      style: TextStyle(
                        color: _getStockColor(merchandise.quantityTotal, merchandise.minimumStock),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}