import '../../data/models/alert_model.dart';
import 'http_client.dart';

class AlertService {
  Future<List<Alert>> fetchStockAlerts() async {
    try {
      final response = await HttpClient.get('/merchandise/stock-alerts');

      if (response.success && response.data != null) {
        final data = response.data!['data'];
        if (data != null && data['alerts'] != null) {
          final List alertsJson = data['alerts'];
          print('AlertService: ${alertsJson.length} alertas encontrados');
          final alerts = alertsJson.map((json) {
            print('AlertService: Processando alerta: $json');
            return Alert.fromJson(json);
          }).toList();
          return alerts;
        }
        print('AlertService: Nenhum alerta encontrado na resposta');
        return [];
      }

      throw Exception(response.message);
    } catch (e) {
      print('AlertService Error: $e');
      throw Exception('Falha ao carregar alertas de estoque');
    }
  }

  Future<List<Alert>> fetchCriticalAlerts() async {
    final alerts = await fetchStockAlerts();
    return alerts.where((alert) => alert.alertType == 'critical').toList();
  }

  Future<List<Alert>> fetchWarningAlerts() async {
    final alerts = await fetchStockAlerts();
    return alerts.where((alert) => alert.alertType == 'warning').toList();
  }

  Future<List<Alert>> fetchLowStockAlerts() async {
    final alerts = await fetchStockAlerts();
    return alerts.where((alert) => alert.alertType == 'low').toList();
  }
}
