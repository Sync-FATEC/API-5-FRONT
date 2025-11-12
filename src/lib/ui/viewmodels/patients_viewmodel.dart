// lib/ui/viewmodels/patients_viewmodel.dart

import 'package:flutter/material.dart';
import '../../core/services/appointment_service.dart';

class PatientsViewModel extends ChangeNotifier {
  final AppointmentService _service;

  PatientsViewModel({AppointmentService? service})
      : _service = service ?? AppointmentService();

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _error;
  String _query = '';

  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;

  Future<void> load({String query = ''}) async {
    _setLoading(true);
    _query = query;
    try {
      final list = await _service.searchPatients(query);
      list.sort((a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));
      _items = list;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

