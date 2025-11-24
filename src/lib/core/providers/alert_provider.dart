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
  bool get hasAlerts => _alerts.isNotEmpty;
  bool get isEmpty => _alerts.isEmpty;

  /// Retorna uma mensagem informativa quando não há alertas
  String get noAlertsMessage => 'Nenhum alerta de estoque encontrado';

  Future<void> loadAlerts({String? stockId}) async {
    print("Iniciando carregamento de alertas");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _alertService.fetchStockAlerts(stockId: stockId);
      print("Alertas carregados: ${_alerts.length}");

      if (_alerts.isEmpty) {
        print("Nenhum alerta encontrado");
      }
    } catch (e) {
      print("Erro ao carregar alertas: $e");
      _errorMessage = 'Erro ao carregar alertas de estoque';
      _alerts = []; // Garantir que a lista esteja vazia em caso de erro
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        // Backend não retorna 'low' neste endpoint de alertas; tratar como 'warning'
        return _alerts.where((alert) => alert.alertType == 'warning' || alert.alertType == 'low').toList();
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
