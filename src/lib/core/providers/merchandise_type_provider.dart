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

  // Getters
  List<MerchandiseTypeModel> get merchandiseTypes => _merchandiseTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MerchandiseTypeModel? get selectedMerchandiseType => _selectedMerchandiseType;

  // Carregar tipos de mercadoria
  Future<void> loadMerchandiseTypes() async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Carregando tipos de mercadoria');
      _merchandiseTypes = await _merchandiseService.fetchMerchandiseTypeList();
      print('MerchandiseTypeProvider: ${_merchandiseTypes.length} tipos carregados');
    } catch (e) {
      print('MerchandiseTypeProvider: Erro ao carregar tipos: $e');
      _setError('Erro ao carregar tipos de mercadoria: $e');
      _merchandiseTypes = [];
    } finally {
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
  Future<bool> createMerchandiseType(MerchandiseTypeModel merchandiseType) async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Criando tipo de mercadoria - Nome: ${merchandiseType.name}');
      await _merchandiseService.createMerchandiseType(merchandiseType);
      
      // Recarregar a lista após criar
      await loadMerchandiseTypes();
      
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
  Future<bool> updateMerchandiseType(MerchandiseTypeModel merchandiseType) async {
    _setLoading(true);
    _setError(null);

    try {
      print('MerchandiseTypeProvider: Atualizando tipo de mercadoria - ID: ${merchandiseType.id}');
      await _merchandiseService.updateMerchandiseType(merchandiseType);
      
      // Recarregar a lista após atualizar
      await loadMerchandiseTypes();
      
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