import 'package:flutter/material.dart';
import '../../core/providers/order_provider.dart';
import '../../core/services/merchandise_service.dart';
import '../../data/models/merchandise_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/merchandise_entry_model.dart';

enum MovementType { entrada, saida }

class InventoryMovement {
  final String id;
  final DateTime date;
  final MovementType type;
  final String productName;
  final String productId;
  final int quantity;
  final String? description;
  final String? status;
  final String? sectionName;

  InventoryMovement({
    required this.id,
    required this.date,
    required this.type,
    required this.productName,
    required this.productId,
    required this.quantity,
    this.description,
    this.status,
    this.sectionName,
  });
}

class InventoryHistoryViewModel extends ChangeNotifier {
  final OrderProvider orderProvider;
  final MerchandiseService merchandiseService;
  
  List<InventoryMovement> _movements = [];
  List<MerchandiseEntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedProductId;

  InventoryHistoryViewModel({
    required this.orderProvider,
    required this.merchandiseService,
  });

  List<InventoryMovement> get movements => _movements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedProductId => _selectedProductId;

  Future<void> loadInventoryHistory({String? productId, String? stockId}) async {
    _isLoading = true;
    _error = null;
    _selectedProductId = productId;
    notifyListeners();

    try {
      // Carregar pedidos (saídas)
      await orderProvider.loadOrders(stockId: stockId);
      
      // Carregar entradas de mercadoria
      await _loadMerchandiseEntries(productId: productId);
      
      // Combinar e ordenar movimentações
      _combineMovements(productId);
      
    } catch (e) {
      _error = 'Erro ao carregar histórico: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMerchandiseEntries({String? productId}) async {
    try {
      // Aqui você pode implementar a busca de entradas específicas
      // Por enquanto, vamos usar uma lista vazia como placeholder
      _entries = [];
    } catch (e) {
      print('Erro ao carregar entradas: $e');
    }
  }

  void _combineMovements(String? productId) {
    List<InventoryMovement> allMovements = [];

    // Adicionar saídas (pedidos)
    for (Order order in orderProvider.orders) {
      for (var item in order.orderItems) {
        // Se um produto específico foi selecionado, filtrar apenas esse produto
        if (productId == null || item.merchandiseId == productId) {
          allMovements.add(InventoryMovement(
            id: '${order.id}_${item.id}',
            date: DateTime.parse(order.creationDate),
            type: MovementType.saida,
            productName: item.merchandiseName,
            productId: item.merchandiseId,
            quantity: item.quantity,
            description: 'Pedido para ${order.sectionName}',
            status: order.status,
            sectionName: order.sectionName,
          ));
        }
      }
    }

    // Adicionar entradas
    for (MerchandiseEntryModel entry in _entries) {
      allMovements.add(InventoryMovement(
        id: entry.id ?? '',
        date: entry.validDate,
        type: MovementType.entrada,
        productName: 'Produto ${entry.recordNumber}',
        productId: entry.recordNumber,
        quantity: entry.quantity,
        description: 'Entrada de estoque',
        status: entry.status,
      ));
    }

    // Ordenar por data (mais recente primeiro)
    allMovements.sort((a, b) => b.date.compareTo(a.date));
    
    _movements = allMovements;
  }

  List<InventoryMovement> getMovementsByType(MovementType type) {
    return _movements.where((movement) => movement.type == type).toList();
  }

  List<InventoryMovement> getMovementsByDateRange(DateTime start, DateTime end) {
    return _movements.where((movement) {
      return movement.date.isAfter(start.subtract(const Duration(days: 1))) &&
             movement.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  int getTotalEntries() {
    return getMovementsByType(MovementType.entrada)
        .fold(0, (sum, movement) => sum + movement.quantity);
  }

  int getTotalExits() {
    return getMovementsByType(MovementType.saida)
        .fold(0, (sum, movement) => sum + movement.quantity);
  }

  int getNetMovement() {
    return getTotalEntries() - getTotalExits();
  }

  void clearHistory() {
    _movements.clear();
    _entries.clear();
    _selectedProductId = null;
    notifyListeners();
  }
}