// lib/core/providers/merchandise_type_provider.dart

import 'package:flutter/foundation.dart';
import '../services/merchandise_service.dart';
import '../../data/models/merchandise_type_model.dart';

class MerchandiseTypeProvider extends ChangeNotifier {
  final MerchandiseService _merchandiseService = MerchandiseService();

  List<MerchandiseTypeModel> _merchandiseTypes = [];
  bool _isLoading = false;
  String? _errorMessage;
  MerchandiseTypeModel? _selectedMerchandiseType;
  String? _currentStockId;

  // Getters
  List<MerchandiseTypeModel> get merchandiseTypes => _merchandiseTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MerchandiseTypeModel? get selectedMerchandiseType => _selectedMerchandiseType;

  // Carregar tipos de mercadoria
  Future<void> loadMerchandiseTypes({String? stockId}) async {
    print('🔄 [MERCHANDISE_TYPE_PROVIDER] Iniciando carregamento de tipos de mercadoria...');
    print('📊 [MERCHANDISE_TYPE_PROVIDER] Estado atual: ${_merchandiseTypes.length} tipos na lista');
    print('🏪 [MERCHANDISE_TYPE_PROVIDER] StockId: $stockId');
    
    // Armazenar o stockId atual para uso em outros métodos
    _currentStockId = stockId;
    
    _setLoading(true);
    _setError(null);

    try {
      print('🌐 [MERCHANDISE_TYPE_PROVIDER] Chamando MerchandiseService...');
      _merchandiseTypes = await _merchandiseService.fetchMerchandiseTypeList(stockId: stockId);
      
      print('✅ [MERCHANDISE_TYPE_PROVIDER] Carregamento concluído!');
      print('📦 [MERCHANDISE_TYPE_PROVIDER] Total de tipos carregados: ${_merchandiseTypes.length}');
      
      if (_merchandiseTypes.isNotEmpty) {
        print('📋 [MERCHANDISE_TYPE_PROVIDER] Lista de tipos carregados:');
        for (var type in _merchandiseTypes) {
          print('   - ${type.name} (ID: ${type.id}, Grupo: ${type.group})');
        }
      } else {
        print('⚠️ [MERCHANDISE_TYPE_PROVIDER] Nenhum tipo de mercadoria foi carregado');
      }
    } catch (e) {
      print('❌ [MERCHANDISE_TYPE_PROVIDER] Erro ao carregar tipos: $e');
      _setError('Erro ao carregar tipos de mercadoria: $e');
      _merchandiseTypes = [];
    } finally {
      print('🏁 [MERCHANDISE_TYPE_PROVIDER] Finalizando carregamento (loading = false)');
      _setLoading(false);
    }
  }

  // Obter tipo de mercadoria por ID
  MerchandiseTypeModel? getMerchandiseTypeById(String id) {
    try {
      return _merchandiseTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  // Criar novo tipo de mercadoria
  Future<bool> createMerchandiseType(MerchandiseTypeModel merchandiseType, {String? stockId}) async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Criando tipo de mercadoria - Nome: ${merchandiseType.name}');
      await _merchandiseService.createMerchandiseType(merchandiseType);
      
      // Recarregar a lista após criar
      await loadMerchandiseTypes(stockId: _currentStockId);
      
      print('MerchandiseTypeProvider: Tipo de mercadoria criado com sucesso');
      return true;
    } catch (e) {
      print('MerchandiseTypeProvider: Erro ao criar tipo: $e');
      _setError('Erro ao criar tipo de mercadoria: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar tipo de mercadoria
  Future<bool> updateMerchandiseType(MerchandiseTypeModel merchandiseType, {String? stockId}) async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Atualizando tipo de mercadoria - ID: ${merchandiseType.id}');
      await _merchandiseService.updateMerchandiseType(merchandiseType);
      
      // Recarregar a lista após atualizar
      await loadMerchandiseTypes(stockId: _currentStockId);
      
      print('MerchandiseTypeProvider: Tipo de mercadoria atualizado com sucesso');
      return true;
    } catch (e) {
      print('MerchandiseTypeProvider: Erro ao atualizar tipo: $e');
      _setError('Erro ao atualizar tipo de mercadoria: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir tipo de mercadoria
  Future<bool> deleteMerchandiseType(String merchandiseTypeId, {String? stockId}) async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Excluindo tipo de mercadoria - ID: $merchandiseTypeId');
      await _merchandiseService.deleteMerchandiseType(merchandiseTypeId);
      
      // Recarregar a lista após excluir
      await loadMerchandiseTypes(stockId: _currentStockId);
      
      print('MerchandiseTypeProvider: Tipo de mercadoria excluído com sucesso');
      return true;
    } catch (e) {
      print('MerchandiseTypeProvider: Erro ao excluir tipo: $e');
      
      // Verificar se é erro de produto em uso em pedidos
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('pedido') || 
          errorMessage.contains('order') || 
          errorMessage.contains('em uso') ||
          errorMessage.contains('in use') ||
          errorMessage.contains('constraint') ||
          errorMessage.contains('foreign key')) {
        _setError('Não é possível excluir este produto pois ele está sendo usado em um ou mais pedidos.');
      } else {
        _setError('Erro ao excluir tipo de mercadoria: $e');
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar quantidade total (apenas para administradores)
  Future<bool> updateQuantityTotal(String merchandiseTypeId, int quantityTotal) async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Atualizando quantidade total - ID: $merchandiseTypeId, Quantidade: $quantityTotal');
      await _merchandiseService.updateQuantityTotal(merchandiseTypeId, quantityTotal);
      
      // Recarregar a lista após atualizar
      await loadMerchandiseTypes(stockId: _currentStockId);
      
      print('MerchandiseTypeProvider: Quantidade total atualizada com sucesso');
      return true;
    } catch (e) {
      print('MerchandiseTypeProvider: Erro ao atualizar quantidade total: $e');
      _setError('Erro ao atualizar quantidade total: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Selecionar tipo de mercadoria
  void selectMerchandiseType(MerchandiseTypeModel merchandiseType) {
    _selectedMerchandiseType = merchandiseType;
    notifyListeners();
  }

  // Limpar seleção de tipo de mercadoria
  void clearSelectedMerchandiseType() {
    _selectedMerchandiseType = null;
    notifyListeners();
  }

  // Limpar dados
  void clearMerchandiseTypes() {
    _merchandiseTypes = [];
    _selectedMerchandiseType = null;
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