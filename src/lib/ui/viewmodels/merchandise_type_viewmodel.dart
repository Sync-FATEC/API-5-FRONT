import 'package:flutter/material.dart';
import '../../core/services/merchandise_service.dart';
import '../../data/models/merchandise_type_model.dart';

class MerchandiseTypeViewModel extends ChangeNotifier {
  final MerchandiseService service;
  List<MerchandiseTypeModel> typeList = [];
  bool isLoading = false;
  String? error;

  MerchandiseTypeViewModel({required this.service});

  Future<void> loadTypes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      typeList = await service.fetchMerchandiseTypeList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addType(MerchandiseTypeModel type) async {
    try {
      await service.createMerchandiseType(type);
      await loadTypes();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateType(MerchandiseTypeModel type) async {
    try {
      await service.updateMerchandiseType(type);
      await loadTypes();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
