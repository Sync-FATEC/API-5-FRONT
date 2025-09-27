import 'package:flutter/material.dart';
import 'package:api2025/data/models/alert_model.dart';
import 'package:intl/intl.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final bool showArrow;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.showArrow = true,
  });

  Color _getAlertColor() {
    switch (alert.alertType) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'low':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  Color _getAlertBackgroundColor() {
    switch (alert.alertType) {
      case 'critical':
        return Colors.red[50]!;
      case 'warning':
        return Colors.orange[50]!;
      case 'low':
        return Colors.yellow[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  String _getAlertText() {
    switch (alert.alertType) {
      case 'critical':
        return 'Crítico';
      case 'warning':
        return 'Médio';
      case 'low':
        return 'Baixo';
      default:
        return alert.alertType;
    }
  }

  IconData _getAlertIcon() {
    switch (alert.alertType) {
      case 'critical':
        return Icons.warning;
      case 'warning':
        return Icons.info;
      case 'low':
        return Icons.notifications;
      default:
        return Icons.circle;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: _getAlertColor(), width: 4)),
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
                  // Ícone do alerta
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getAlertBackgroundColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAlertIcon(),
                      color: _getAlertColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nome da mercadoria e seção
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.merchandiseName.isNotEmpty
                              ? alert.merchandiseName
                              : 'Nome não informado',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.sectionName.isNotEmpty
                              ? alert.sectionName
                              : 'Seção não informada',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
            // Conteúdo do estoque
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações de estoque
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estoque Atual',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${alert.currentStock} unidades',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estoque Mínimo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${alert.minimumStock} unidades',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Badge do tipo de alerta
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getAlertBackgroundColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getAlertText(),
                      style: TextStyle(
                        color: _getAlertColor(),
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
            // Data de atualização
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Text(
                _formatDate(alert.lastUpdated),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
