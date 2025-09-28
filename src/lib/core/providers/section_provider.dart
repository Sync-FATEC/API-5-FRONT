// lib/core/providers/section_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../../data/models/section_model.dart';

class SectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<SectionModel> _sections = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SectionModel> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar seções
  Future<void> loadSections() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getSections();
      
      if (response != null && response.success) {
        _sections = response.data.map((sectionData) => 
          SectionModel(
            id: sectionData.id,
            name: sectionData.name,
          )
        ).toList();
        
        notifyListeners();
      } else {
        _setError('Erro ao carregar seções');
      }
    } catch (e) {
      _setError('Erro ao carregar seções: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpar erro manualmente
  void clearError() {
    _clearError();
  }

  // Criar nova seção
  Future<bool> createSection(String name) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.createSection(name);
      
      if (response != null && response.success && response.data.isNotEmpty) {
        // Adicionando a nova seção à lista local
        final newSectionData = response.data.first;
        final newSection = SectionModel(
          id: newSectionData.id,
          name: newSectionData.name,
        );
        _sections.add(newSection);
        notifyListeners();
        return true;
      } else {
        _setError('Erro ao criar seção');
        return false;
      }
    } catch (e) {
      _setError('Erro ao criar seção: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Excluir seção
  Future<bool> deleteSection(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Chamando a API para excluir a seção
      final success = await _apiService.deleteSection(id);
      
      if (success) {
        // Removendo a seção da lista local apenas se a API retornou sucesso
        _sections.removeWhere((section) => section.id == id);
        notifyListeners();
        return true;
      } else {
        _setError('Erro ao excluir seção');
        return false;
      }
    } catch (e) {
      _setError('Erro ao excluir seção: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar seção
  Future<bool> updateSection(String id, String name) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.updateSection(id, name);
      
      if (response != null && response.success && response.data.isNotEmpty) {
        // Atualizando a seção na lista local
        final updatedSectionData = response.data.first;
        final index = _sections.indexWhere((section) => section.id == id);
        
        if (index != -1) {
          _sections[index] = SectionModel(
            id: updatedSectionData.id,
            name: updatedSectionData.name,
          );
          notifyListeners();
        }
        return true;
      } else {
        _setError('Erro ao atualizar seção');
        return false;
      }
    } catch (e) {
      _setError('Erro ao atualizar seção: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}