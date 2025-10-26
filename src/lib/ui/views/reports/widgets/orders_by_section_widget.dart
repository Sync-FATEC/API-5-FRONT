import 'package:flutter/material.dart';
import '../../../../data/models/orders_by_section_model.dart';

class OrdersBySectionWidget extends StatefulWidget {
  final List<OrdersBySection>? ordersBySection;

  const OrdersBySectionWidget({super.key, this.ordersBySection});

  @override
  State<OrdersBySectionWidget> createState() => _OrdersBySectionWidgetState();
}

class _OrdersBySectionWidgetState extends State<OrdersBySectionWidget> {
  static const int itemsPerPage = 5;
  int currentPage = 1;

  List<OrdersBySection> get paginatedData {
    if (widget.ordersBySection == null || widget.ordersBySection!.isEmpty) {
      return [];
    }

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      widget.ordersBySection!.length,
    );
    return widget.ordersBySection!.sublist(startIndex, endIndex);
  }

  int get totalPages {
    if (widget.ordersBySection == null || widget.ordersBySection!.isEmpty) {
      return 1;
    }
    return (widget.ordersBySection!.length / itemsPerPage).ceil();
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

  // Calcula a porcentagem para a barra de progresso baseada no maior valor
  double _calculatePercentage(int orderCount) {
    if (widget.ordersBySection == null || widget.ordersBySection!.isEmpty) {
      return 0;
    }

    final maxCount = widget.ordersBySection!
        .map((e) => e.orderCount)
        .reduce((max, current) => current > max ? current : max);

    if (maxCount == 0) return 0;
    return (orderCount / maxCount) * 100;
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
                  'Pedidos por Seção',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (widget.ordersBySection != null &&
                    widget.ordersBySection!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.ordersBySection!.length} total)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Conteúdo
            if (widget.ordersBySection == null ||
                widget.ordersBySection!.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sem dados por seção',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Lista de seções
              Column(
                children: paginatedData.map((item) {
                  final percentage = _calculatePercentage(item.orderCount);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Nome da seção
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.sectionName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Barra de progresso
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade200,
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Contador
                        SizedBox(
                          width: 48,
                          child: Text(
                            item.orderCount.toString(),
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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
