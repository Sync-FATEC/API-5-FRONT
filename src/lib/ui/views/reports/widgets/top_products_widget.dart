import 'package:flutter/material.dart';
import '../../../../data/models/top_product_model.dart';

class TopProductsWidget extends StatefulWidget {
  final List<TopProduct>? topProducts;

  const TopProductsWidget({super.key, this.topProducts});

  @override
  State<TopProductsWidget> createState() => _TopProductsWidgetState();
}

class _TopProductsWidgetState extends State<TopProductsWidget> {
  static const int itemsPerPage = 5;
  int currentPage = 1;

  List<TopProduct> get paginatedData {
    if (widget.topProducts == null || widget.topProducts!.isEmpty) {
      return [];
    }

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      widget.topProducts!.length,
    );
    return widget.topProducts!.sublist(startIndex, endIndex);
  }

  int get totalPages {
    if (widget.topProducts == null || widget.topProducts!.isEmpty) {
      return 1;
    }
    return (widget.topProducts!.length / itemsPerPage).ceil();
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
  double _calculatePercentage(int totalQuantity) {
    if (widget.topProducts == null || widget.topProducts!.isEmpty) {
      return 0;
    }

    final maxQuantity = widget.topProducts!
        .map((e) => e.totalQuantity)
        .reduce((max, current) => current > max ? current : max);

    if (maxQuantity == 0) return 0;
    return (totalQuantity / maxQuantity) * 100;
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
                  'Top Produtos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (widget.topProducts != null &&
                    widget.topProducts!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.topProducts!.length} total)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Conteúdo
            if (widget.topProducts == null || widget.topProducts!.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sem dados de top produtos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Lista de produtos
              Column(
                children: paginatedData.map((item) {
                  final percentage = _calculatePercentage(item.totalQuantity);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        // Layout mobile: Column
                        if (MediaQuery.of(context).size.width < 600) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nome do produto
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Barra de progresso
                              Container(
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
                                      color: Colors.blue.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Informações
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.totalQuantity.toString(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Text(
                                      'Pedidos: ${item.orderCount}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]
                        // Layout desktop: Row
                        else ...[
                          Row(
                            children: [
                              // Nome do produto
                              SizedBox(
                                width: 160,
                                child: Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Barra de progresso
                              Expanded(
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
                                        color: Colors.blue.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Informações
                              Row(
                                children: [
                                  SizedBox(
                                    width: 64,
                                    child: Text(
                                      item.totalQuantity.toString(),
                                      textAlign: TextAlign.right,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Text(
                                      'Pedidos: ${item.orderCount}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
