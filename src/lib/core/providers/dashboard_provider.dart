import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../../data/models/dashboard_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar dashboard completo
  Future<void> loadDashboard({
    required String stockId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool includeOrders = true,
    bool includeMerchandise = true,
    bool includeStock = true,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      print('DashboardProvider: Carregando dashboard para stockId: $stockId');
      final response = await _apiService.getCompleteDashboard(
        stockId: stockId,
        period: period,
        startDate: startDate,
        endDate: endDate,
        includeOrders: includeOrders,
        includeMerchandise: includeMerchandise,
        includeStock: includeStock,
      );

      print(
        'DashboardProvider: Response recebida - success: ${response?.success}, data: ${response?.data != null}',
      );

      if (response != null && response.success && response.data != null) {
        _dashboardData = response.data;
        print('DashboardProvider: Dashboard carregado com sucesso');
        print('DashboardProvider: StockName: ${_dashboardData?.stockName}');
        print('DashboardProvider: Orders: ${_dashboardData?.orders?.length}');
      } else {
        throw Exception(response?.message ?? 'Erro ao carregar dashboard');
      }
    } catch (e) {
      print('DashboardProvider: Erro detalhado ao carregar dashboard: $e');
      print('DashboardProvider: Tipo do erro: ${e.runtimeType}');
      _setError('Erro ao carregar dashboard: $e');
      _dashboardData = null;
    } finally {
      _setLoading(false);
    }
  }

  // Limpar dados do dashboard
  void clearDashboard() {
    _dashboardData = null;
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
