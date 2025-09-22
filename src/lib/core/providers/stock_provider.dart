// lib/core/providers/stock_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StockProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<StockData> _stocks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<StockData> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar estoques do usuário
  Future<void> loadStocks(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      print('StockProvider: Carregando estoques para userId: $userId');
      final response = await _apiService.getStocks(userId);
      
      if (response != null && response.success) {
        _stocks = response.data;
        print('StockProvider: ${_stocks.length} estoques carregados');
      } else {
        throw Exception(response?.message ?? 'Erro ao carregar estoques');
      }
    } catch (e) {
      print('StockProvider: Erro ao carregar estoques: $e');
      _setError('Erro ao carregar estoques: $e');
      _stocks = [];
    } finally {
      _setLoading(false);
    }
  }

  // Obter estoque por ID
  StockData? getStockById(String id) {
    try {
      return _stocks.firstWhere((stock) => stock.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obter estoques ativos
  List<StockData> get activeStocks {
    return _stocks.where((stock) => stock.active).toList();
  }

  // Criar novo estoque
  Future<bool> createStock(String name, String location) async {
    _setLoading(true);
    _setError(null);

    try {
      print('StockProvider: Criando estoque - Nome: $name, Localização: $location');
      final response = await _apiService.createStock(name, location);
      
      if (response != null && response.success) {
        // Adicionar o novo estoque à lista local se retornado
        if (response.data.isNotEmpty) {
          _stocks.addAll(response.data);
        }
        print('StockProvider: Estoque criado com sucesso');
        return true;
      } else {
        throw Exception(response?.message ?? 'Erro ao criar estoque');
      }
    } catch (e) {
      print('StockProvider: Erro ao criar estoque: $e');
      _setError('Erro ao criar estoque: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir estoque
  Future<bool> deleteStock(String stockId) async {
    _setLoading(true);
    _setError(null);

    try {
      print('StockProvider: Excluindo estoque - ID: $stockId');
      final success = await _apiService.deleteStock(stockId);
      
      if (success) {
        // Remover o estoque da lista local
        _stocks.removeWhere((stock) => stock.id == stockId);
        print('StockProvider: Estoque excluído com sucesso');
        return true;
      } else {
        throw Exception('Erro ao excluir estoque');
      }
    } catch (e) {
      print('StockProvider: Erro ao excluir estoque: $e');
      _setError('Erro ao excluir estoque: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Limpar dados
  void clearStocks() {
    _stocks = [];
    _errorMessage = null;
    notifyListeners();
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}