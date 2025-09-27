import 'package:flutter/foundation.dart';
import '../services/alert_service.dart';
import '../../data/models/alert_model.dart';

class AlertProvider extends ChangeNotifier {
  final AlertService _alertService = AlertService();

  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAlerts() async {
    print("Iniciando carregamento de alertas");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _alertService.fetchStockAlerts();
      print("Alertas carregados: ${_alerts.length}");

      // Se não há dados do backend, criar alertas de exemplo para teste
      if (_alerts.isEmpty) {
        print("Criando alertas de exemplo para demonstração");
        _alerts = _createSampleAlerts();
      }
    } catch (e) {
      print("Erro ao carregar alertas: $e");
      _errorMessage = 'Erro ao carregar alertas de estoque';
      // Criar alertas de exemplo em caso de erro para demonstração
      _alerts = _createSampleAlerts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar alertas de exemplo para demonstração
  List<Alert> _createSampleAlerts() {
    return [
      Alert(
        id: '1',
        merchandiseName: 'Paracetamol 500mg',
        merchandiseId: 'med001',
        currentStock: 5,
        minimumStock: 20,
        alertType: 'critical',
        sectionName: 'Farmácia Central',
        sectionId: 'sec001',
        lastUpdated: DateTime.now(),
      ),
      Alert(
        id: '2',
        merchandiseName: 'Gaze Estéril 10x10cm',
        merchandiseId: 'mat001',
        currentStock: 15,
        minimumStock: 30,
        alertType: 'warning',
        sectionName: 'Almoxarifado',
        sectionId: 'sec002',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Alert(
        id: '3',
        merchandiseName: 'Seringa 10ml Descartável',
        merchandiseId: 'mat002',
        currentStock: 25,
        minimumStock: 35,
        alertType: 'low',
        sectionName: 'Centro Cirúrgico',
        sectionId: 'sec003',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  // Filtrar alertas por tipo
  List<Alert> getFilteredAlerts(String filter) {
    switch (filter.toUpperCase()) {
      case 'TODOS':
        return _alerts;
      case 'CRÍTICOS':
        return _alerts.where((alert) => alert.alertType == 'critical').toList();
      case 'MÉDIOS':
        return _alerts.where((alert) => alert.alertType == 'warning').toList();
      case 'BAIXOS':
        return _alerts.where((alert) => alert.alertType == 'low').toList();
      default:
        return _alerts;
    }
  }

  // Buscar alertas por texto
  List<Alert> searchAlerts(String query) {
    if (query.isEmpty) {
      return _alerts;
    }

    return _alerts.where((alert) {
      return alert.merchandiseName.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          alert.sectionName.toLowerCase().contains(query.toLowerCase()) ||
          alert.id.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Combinar filtro e busca
  List<Alert> getFilteredAndSearchedAlerts(String filter, String searchQuery) {
    List<Alert> filteredAlerts = getFilteredAlerts(filter);

    if (searchQuery.isNotEmpty) {
      filteredAlerts = filteredAlerts.where((alert) {
        return alert.merchandiseName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            alert.sectionName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            alert.id.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filteredAlerts;
  }

  // Limpar dados
  void clearAlerts() {
    _alerts = [];
    _errorMessage = null;
    notifyListeners();
  }

  // Métodos para estatísticas
  int get criticalAlertsCount =>
      _alerts.where((alert) => alert.isCritical).length;
  int get warningAlertsCount =>
      _alerts.where((alert) => alert.isWarning).length;
  int get lowStockAlertsCount => _alerts.where((alert) => alert.isLow).length;
  int get totalAlertsCount => _alerts.length;
}
