import 'package:flutter/material.dart';
import '../../core/services/merchandise_service.dart';
import '../../data/models/merchandise_model.dart';

class MerchandiseViewModel extends ChangeNotifier {
  final MerchandiseService service;
  List<MerchandiseModel> merchandiseList = [];
  bool isLoading = false;
  String? error;

  MerchandiseViewModel({required this.service});

  Future<void> loadMerchandise() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      merchandiseList = await service.fetchMerchandiseList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addMerchandise(MerchandiseModel merchandise) async {
    try {
      await service.createMerchandise(merchandise);
      await loadMerchandise();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateMerchandise(MerchandiseModel merchandise) async {
    try {
      await service.updateMerchandise(merchandise);
      await loadMerchandise();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
