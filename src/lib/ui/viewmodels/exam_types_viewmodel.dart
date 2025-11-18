// lib/ui/viewmodels/exam_types_viewmodel.dart

import 'package:flutter/material.dart';
import '../../core/services/exam_service.dart';
import '../../data/models/exam_type_model.dart';

/// ViewModel para gerenciamento de Tipos de Exame
/// - Controla estados de carregamento e erro
/// - Expõe ações CRUD
class ExamTypesViewModel extends ChangeNotifier {
  final ExamService _service;

  ExamTypesViewModel({ExamService? service})
    : _service = service ?? ExamService();

  // Estado
  List<ExamTypeModel> _allItems = [];
  List<ExamTypeModel> _filteredItems = [];
  ExamTypeModel? _selected;
  bool _isLoading = false;
  String? _error;
  String? _currentQuery;

  // Getters
  List<ExamTypeModel> get items => _filteredItems;
  ExamTypeModel? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({String? query, bool? isActive}) async {
    _setLoading(true);
    try {
      // Carrega sempre sem query para ter a lista completa
      _allItems = await _service.fetchExamTypes(isActive: isActive);
      _currentQuery = query;
      _applyFilter();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _applyFilter() {
    if (_currentQuery == null || _currentQuery!.isEmpty) {
      _filteredItems = _allItems;
    } else {
      final queryLower = _currentQuery!.toLowerCase();
      _filteredItems = _allItems
          .where((item) => item.name.toLowerCase().contains(queryLower))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> create(ExamTypeModel model) async {
    // Validações simples
    if (!model.isValidName) {
      _error = 'Nome do exame é obrigatório';
      notifyListeners();
      return false;
    }
    if (!model.isValidDuration) {
      _error = 'Duração estimada deve ser maior que 0 e menor que 480 minutos';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final created = await _service.createExamType(model);
      _allItems = [created, ..._allItems];
      _applyFilter();
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> fields) async {
    if (id.isEmpty) {
      _error = 'ID do tipo de exame é obrigatório para atualização';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    try {
      final updated = await _service.updateExamType(id, fields);
      _allItems = _allItems.map((e) => e.id == id ? updated : e).toList();
      _applyFilter();
      _selected = updated;
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> remove(String id) async {
    _setLoading(true);
    try {
      await _service.deleteExamType(id);
      _allItems = _allItems.where((e) => e.id != id).toList();
      _applyFilter();
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void select(ExamTypeModel? model) {
    _selected = model;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
