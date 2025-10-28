import 'package:flutter/material.dart';
import '../../core/providers/order_provider.dart';
import '../../core/services/merchandise_service.dart';
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
  String? _selectedProductName;

  InventoryHistoryViewModel({
    required this.orderProvider,
    required this.merchandiseService,
  });

  List<InventoryMovement> get movements => _movements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedProductId => _selectedProductId;
  String? get selectedProductName => _selectedProductName;

  Future<void> loadInventoryHistory({String? productId, String? stockId}) async {
    _isLoading = true;
    _error = null;
    _selectedProductId = productId;
    _selectedProductName = null;
    notifyListeners();

    try {
      // Carregar pedidos (saídas)
      await orderProvider.loadOrders(stockId: stockId);
      
      // Se temos um productId, buscar informações do produto e entradas
      if (productId != null) {
        // Primeiro carregar informações do produto para ter o nome
        await _loadProductInfo(productId);
        
        // Depois carregar entradas
        await _loadMerchandiseEntries(productId: productId);
        
        // Combinar e ordenar movimentações APÓS ter o nome do produto
        _combineMovements(productId);
        
        // Notificar mudanças para atualizar a UI com o nome do produto
        notifyListeners();
      } else {
        _entries = [];
        // Combinar e ordenar movimentações
        _combineMovements(productId);
      }
      
    } catch (e) {
      _error = 'Erro ao carregar histórico: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProductInfo(String productId) async {
    try {
      print('InventoryHistoryViewModel: Buscando informações do produto ID: $productId');
      final product = await merchandiseService.fetchMerchandiseTypeById(productId);
      print('InventoryHistoryViewModel: Produto retornado - Nome: "${product.name}"');
      
      _selectedProductName = product.name;
      print('InventoryHistoryViewModel: Nome do produto definido como: "$_selectedProductName"');
      
      // Verificar se o nome foi realmente definido
      if (_selectedProductName == null || _selectedProductName!.isEmpty) {
        print('InventoryHistoryViewModel: ERRO - Nome do produto está vazio após carregamento!');
        _selectedProductName = 'Produto';
      } else {
        print('InventoryHistoryViewModel: ✅ Nome do produto carregado com sucesso: "$_selectedProductName"');
      }
    } catch (e) {
      print('InventoryHistoryViewModel: ❌ Erro ao carregar informações do produto: $e');
      _selectedProductName = 'Produto';
    }
  }

  Future<void> _loadMerchandiseEntries({String? productId}) async {
    try {
      if (productId != null) {
        // Buscar histórico de entradas do backend
        final entryHistoryData = await merchandiseService.fetchEntryHistory(productId);
        
        // Converter os dados do backend para MerchandiseEntryModel
        _entries = entryHistoryData.map<MerchandiseEntryModel>((entryData) {
          return MerchandiseEntryModel(
            id: entryData['id'],
            recordNumber: '', // Não temos recordNumber no EntryHistory
            quantity: entryData['quantity'] ?? 0,
            validDate: DateTime.parse(entryData['entryDate']),
            status: 'COMPLETED', // Entradas são sempre completadas
          );
        }).toList();
        
        print('InventoryHistoryViewModel: Carregadas ${_entries.length} entradas do backend');
      } else {
        _entries = [];
      }
    } catch (e) {
      print('Erro ao carregar entradas: $e');
      _entries = [];
    }
  }

  void _combineMovements(String? productId) {
    print('InventoryHistoryViewModel: Combinando movimentações...');
    print('InventoryHistoryViewModel: Nome do produto atual: $_selectedProductName');
    print('InventoryHistoryViewModel: Quantidade de entradas: ${_entries.length}');
    
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
      // Garantir que sempre temos o nome correto do produto
      String productName;
      if (_selectedProductName != null && _selectedProductName!.isNotEmpty) {
        productName = _selectedProductName!;
        print('InventoryHistoryViewModel: Usando nome carregado: $productName');
      } else {
        productName = 'Produto';
        print('InventoryHistoryViewModel: Usando nome genérico: $productName');
      }
      
      allMovements.add(InventoryMovement(
        id: entry.id ?? '',
        date: entry.validDate,
        type: MovementType.entrada,
        productName: productName,
        productId: productId ?? '',
        quantity: entry.quantity,
        description: 'Entrada de estoque',
        status: entry.status,
      ));
    }

    // Ordenar por data (mais recente primeiro)
    allMovements.sort((a, b) => b.date.compareTo(a.date));
    
    _movements = allMovements;
    print('InventoryHistoryViewModel: Total de movimentações criadas: ${_movements.length}');
  }

  String _getProductNameForEntry(MerchandiseEntryModel entry, String? productId) {
    // SEMPRE usar o nome do produto carregado se disponível
    if (_selectedProductName != null && _selectedProductName!.isNotEmpty) {
      print('InventoryHistoryViewModel: Usando nome do produto: $_selectedProductName');
      return _selectedProductName!;
    }
    
    // Se não temos o nome, usar um nome genérico mais amigável
    if (productId != null) {
      print('InventoryHistoryViewModel: Nome do produto não disponível para ID: $productId');
      // Retornar um nome mais amigável baseado no ID
      return 'Produto';
    }
    return 'Entrada de Mercadoria';
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
    _selectedProductName = null;
    notifyListeners();
  }
}