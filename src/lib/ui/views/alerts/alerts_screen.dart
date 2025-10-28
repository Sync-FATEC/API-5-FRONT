import 'package:flutter/material.dart';
import 'package:api2025/ui/widgets/background_header.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/ui/widgets/bottom_nav_bar_widget.dart';
import 'package:api2025/ui/widgets/alert_card.dart';
import 'package:api2025/data/models/alert_model.dart';
import 'package:api2025/core/providers/alert_provider.dart';
import 'package:provider/provider.dart';

class AlertsScreen extends StatefulWidget {
  final String title;
  final List<String> filterOptions;

  const AlertsScreen({
    super.key,
    this.title = "LISTAGEM DE ALERTAS",
    this.filterOptions = const ['TODOS', 'CRÍTICOS', 'MÉDIOS', 'BAIXOS'],
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'TODOS';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Carregar alertas após o build da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlerts();
    });
  }

  void _loadAlerts() {
    print("Método _loadAlerts chamado");
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
    alertProvider.loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Header(title: "ALERTAS", sizeHeader: 450),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                // Campo de busca
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        // TODO: Implementar lógica de busca quando adicionar alertas
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildFilterButton(filter, isSelected, () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Lista de alertas
                // Lista de alertas
                Expanded(
                  child: Consumer<AlertProvider>(
                    builder: (context, alertProvider, child) {
                      if (alertProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bluePrimary,
                          ),
                        );
                      }

                      if (alertProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Erro ao carregar alertas',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAlerts,
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

                      // Filtrar e buscar alertas
                      List<Alert> filteredAlerts = alertProvider
                          .getFilteredAndSearchedAlerts(
                            _selectedFilter,
                            _searchQuery,
                          );

                      if (filteredAlerts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: AppColors.bluePrimary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhum alerta encontrado',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.bluePrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Nenhum alerta encontrado para "$_searchQuery"'
                                    : 'Todos os estoques estão em níveis adequados',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: filteredAlerts.length,
                        itemBuilder: (context, index) {
                          final alert = filteredAlerts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: AlertCard(
                              alert: alert,
                              showArrow: false,
                              onTap: () {
                                // TODO: Implementar navegação para detalhes do alerta
                                print(
                                  "Alerta selecionado: ${alert.merchandiseName}",
                                );
                              },
                            ),
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
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 2),
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
