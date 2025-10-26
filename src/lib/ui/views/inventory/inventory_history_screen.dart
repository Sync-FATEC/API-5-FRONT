import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/inventory_history_viewmodel.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/services/merchandise_service.dart';
import '../../../core/providers/stock_provider.dart';

class InventoryHistoryScreen extends StatefulWidget {
  final String? productId;
  final String? productName;

  const InventoryHistoryScreen({
    super.key,
    this.productId,
    this.productName,
  });

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  late InventoryHistoryViewModel _viewModel;
  String _selectedFilter = 'TODOS';
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _viewModel = InventoryHistoryViewModel(
      orderProvider: Provider.of<OrderProvider>(context, listen: false),
      merchandiseService: MerchandiseService(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final selectedStock = stockProvider.selectedStock;
    
    await _viewModel.loadInventoryHistory(
      productId: widget.productId,
      stockId: selectedStock?.id,
    );
  }

  Widget _buildCustomHeader() {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF2563EB)),
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    widget.productName != null 
                        ? 'Histórico - ${widget.productName}'
                        : 'Histórico de Inventário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Stack(
          children: [
            // Fundo azul curvado
            _buildCustomHeader(),
            // Conteúdo sobreposto ao fundo azul (como nas outras telas)
            Padding(
              padding: const EdgeInsets.only(top: 140.0),
              child: SizedBox.expand(
                child: Consumer<InventoryHistoryViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    );
                  }

                  if (viewModel.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.error!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Resumo das movimentações
                      _buildSummaryCard(viewModel),
                      
                      // Filtros
                      _buildFilterSection(),
                      
                      // Filtro por data
                      _buildDateFilterSection(),
                      
                      // Lista de movimentações
                      Expanded(
                        child: _buildMovementsList(viewModel),
                      ),
                    ],
                  );
                },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(InventoryHistoryViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo das Movimentações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Entradas',
                  viewModel.getTotalEntries().toString(),
                  Colors.green,
                  Icons.arrow_downward,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Saídas',
                  viewModel.getTotalExits().toString(),
                  Colors.red,
                  Icons.arrow_upward,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Saldo',
                  viewModel.getNetMovement().toString(),
                  viewModel.getNetMovement() >= 0 ? Colors.green : Colors.red,
                  viewModel.getNetMovement() >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'TODOS',
                  label: Text('Todos'),
                ),
                ButtonSegment<String>(
                  value: 'ENTRADA',
                  label: Text('Entradas'),
                ),
                ButtonSegment<String>(
                  value: 'SAIDA',
                  label: Text('Saídas'),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por período:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectStartDate(),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _startDate != null 
                        ? 'De: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                        : 'Data inicial',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectEndDate(),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _endDate != null 
                        ? 'Até: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                        : 'Data final',
                  ),
                ),
              ),
            ],
          ),
          if (_startDate != null || _endDate != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpar filtros de data'),
            ),
          ],
        ],
      ),
    );
  }



  List<InventoryMovement> get _filteredMovements {
    var movements = _viewModel.movements;
    
    // Filtro por tipo
    if (_selectedFilter != 'TODOS') {
      movements = movements.where((movement) => 
        movement.type.toString().split('.').last == _selectedFilter
      ).toList();
    }
    
    // Filtro por data
    if (_startDate != null || _endDate != null) {
      movements = movements.where((movement) {
        final movementDate = movement.date;
        
        if (_startDate != null && movementDate.isBefore(_startDate!)) {
          return false;
        }
        
        if (_endDate != null) {
          final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (movementDate.isAfter(endOfDay)) {
            return false;
          }
        }
        
        return true;
      }).toList();
    }
    
    return movements;
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Se a data final for anterior à inicial, limpa a data final
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Widget _buildMovementsList(InventoryHistoryViewModel viewModel) {
    final filteredMovements = _filteredMovements;

    if (filteredMovements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma movimentação encontrada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredMovements.length,
      itemBuilder: (context, index) {
        final movement = filteredMovements[index];
        return _buildMovementCard(movement);
      },
    );
  }

  Widget _buildMovementCard(InventoryMovement movement) {
    final isEntry = movement.type == MovementType.entrada;
    final color = isEntry ? Colors.green : Colors.red;
    final icon = isEntry ? Icons.add_circle : Icons.remove_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _dateFormat.format(movement.date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (movement.description != null) ...[
              const SizedBox(height: 2),
              Text(
                movement.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (movement.sectionName != null) ...[
              const SizedBox(height: 2),
              Text(
                'Seção: ${movement.sectionName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isEntry ? '+' : '-'}${movement.quantity}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (movement.status != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(movement.status!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getStatusColor(movement.status!).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(movement.status!),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(movement.status!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'PENDENTE';
      case 'COMPLETED':
        return 'CONCLUÍDO';
      case 'CANCELLED':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }
}

// Classe para criar a forma curvada do cabeçalho
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}