import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/ui/widgets/bottom_nav_bar_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/providers/stock_provider.dart';
import 'widgets/filters_section.dart';
import 'widgets/stock_info_widget.dart';
import 'widgets/orders_list_widget.dart';
import 'widgets/orders_by_section_widget.dart';
import 'widgets/stock_alerts_widget.dart';
import 'widgets/top_products_widget.dart';

class ReportsScreen extends StatefulWidget {
  final String title;
  final List<String> filterOptions;

  const ReportsScreen({
    super.key,
    this.title = "LISTAGEM DE ALERTAS",
    this.filterOptions = const ['TODOS', 'CRÍTICOS', 'MÉDIOS', 'BAIXOS'],
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenScreenState();
}

class _ReportsScreenScreenState extends State<ReportsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? stockId;

  @override
  void initState() {
    super.initState();
    // Definir datas padrão: 1º de janeiro do ano atual até hoje
    final now = DateTime.now();
    startDate = DateTime(now.year, 1, 1);
    endDate = now;

    // Carregar dados iniciais após o widget estar construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final selectedStock = stockProvider.selectedStock;

    if (selectedStock != null) {
      stockId = selectedStock.id;
      _updateData();
    }
  }

  void _updateData() {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    final currentStockId = stockId ?? stockProvider.selectedStock?.id;

    print('=== CARREGANDO DASHBOARD ===');
    print('StockId: $currentStockId');
    print('StartDate: $startDate');
    print('EndDate: $endDate');
    print('StartDate ISO: ${startDate?.toIso8601String()}');
    print('EndDate ISO: ${endDate?.toIso8601String()}');

    if (currentStockId != null && startDate != null && endDate != null) {
      print('Iniciando chamada para dashboard...');
      dashboardProvider.loadDashboard(
        stockId: currentStockId,
        startDate: startDate,
        endDate: endDate,
        includeOrders: true,
        includeMerchandise: true,
        includeStock: true,
      );
    } else {
      print('❌ Erro: Dados insuficientes para carregar dashboard');
      if (currentStockId == null) print('- StockId não encontrado');
      if (startDate == null) print('- Data inicial não definida');
      if (endDate == null) print('- Data final não definida');
    }
    print('==============================');
  }

  void _downloadPDF() {
    // Implementar lógica para download de PDF
    print('Baixando PDF...');
  }

  void _downloadExcel() {
    // Implementar lógica para download de Excel
    print('Baixando Excel...');
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? startDate ?? DateTime.now()
          : endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      // Atualizar dashboard quando as datas mudarem
      _updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(title: "Dashboard do Estoque", sizeHeader: 450),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                Consumer2<StockProvider, DashboardProvider>(
                  builder: (context, stockProvider, dashboardProvider, child) {
                    final selectedStock = stockProvider.selectedStock;
                    final displayStockId = selectedStock?.id ?? stockId;

                    return FiltersSection(
                      startDate: startDate,
                      endDate: endDate,
                      stockId: displayStockId,
                      onSelectDate: _selectDate,
                      onUpdateData: _updateData,
                      onDownloadPDF: _downloadPDF,
                      onDownloadExcel: _downloadExcel,
                    );
                  },
                ),
                // Área dos widgets do dashboard
                Expanded(
                  child: SingleChildScrollView(
                    child: Consumer<DashboardProvider>(
                      builder: (context, dashboardProvider, child) {
                        final dashboardData = dashboardProvider.dashboardData;

                        if (dashboardProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(50),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (dashboardProvider.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Erro ao carregar dados',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dashboardProvider.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _updateData,
                                    child: const Text('Tentar Novamente'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (dashboardData != null) {
                          return Column(
                            children: [
                              // Widget de informações do estoque
                              StockInfoWidget(
                                stockName: dashboardData.stockName,
                                stockLocation: dashboardData.stockLocation,
                              ),
                              // Widget de pedidos por seção
                              OrdersBySectionWidget(
                                ordersBySection: dashboardData.ordersBySection,
                              ),
                              // Widget de alertas de estoque
                              StockAlertsWidget(
                                stockAlerts: dashboardData.stockAlerts,
                              ),
                              // Widget de top produtos
                              TopProductsWidget(
                                topProducts: dashboardData.topProducts,
                              ),
                              // Widget de pedidos
                              OrdersListWidget(orders: dashboardData.orders),
                              const SizedBox(height: 20),
                            ],
                          );
                        }

                        // Estado inicial
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Clique em "Atualizar" para carregar o dashboard',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 3),
    );
  }
}
