import 'package:flutter/material.dart';
import '../../../../data/models/stock_alert_model.dart';

class StockAlertsWidget extends StatefulWidget {
  final List<StockAlert>? stockAlerts;

  const StockAlertsWidget({super.key, this.stockAlerts});

  @override
  State<StockAlertsWidget> createState() => _StockAlertsWidgetState();
}

class _StockAlertsWidgetState extends State<StockAlertsWidget> {
  static const int itemsPerPage = 5;
  int currentPage = 1;

  List<StockAlert> get paginatedData {
    if (widget.stockAlerts == null || widget.stockAlerts!.isEmpty) {
      return [];
    }

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      widget.stockAlerts!.length,
    );
    return widget.stockAlerts!.sublist(startIndex, endIndex);
  }

  int get totalPages {
    if (widget.stockAlerts == null || widget.stockAlerts!.isEmpty) {
      return 1;
    }
    return (widget.stockAlerts!.length / itemsPerPage).ceil();
  }

  bool get canGoPrev => currentPage > 1;
  bool get canGoNext => currentPage < totalPages;

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'crítico':
      case 'critical':
        return Colors.red;
      case 'baixo':
      case 'low':
        return Colors.orange;
      case 'médio':
      case 'medium':
        return Colors.yellow.shade700;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Text(
                  'Alertas de Estoque',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (widget.stockAlerts != null &&
                    widget.stockAlerts!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.stockAlerts!.length} total)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Conteúdo
            if (widget.stockAlerts == null || widget.stockAlerts!.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sem alertas de estoque',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Lista de alertas
              Column(
                children: paginatedData.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do produto
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        // Linha com badge e informações
                        Row(
                          children: [
                            // Badge de status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _getStatusColor(item.status),
                                ),
                              ),
                              child: Text(
                                item.status.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: _getStatusColor(item.status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Informações de estoque
                            Text(
                              'Em estoque: ${item.inStock}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Mínimo: ${item.minimumStock}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Paginação (se necessária)
              if (totalPages > 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: canGoPrev
                          ? () => goToPage(currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Página $currentPage de $totalPages',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      onPressed: canGoNext
                          ? () => goToPage(currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
