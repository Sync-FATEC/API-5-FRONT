import '../models/dashboard_model.dart';

class DashboardApiResponse {
  final bool success;
  final String message;
  final DashboardModel? data;

  DashboardApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DashboardApiResponse.fromJson(Map<String, dynamic> json) {
    print('DashboardApiResponse.fromJson recebido: ${json.keys.toList()}');

    try {
      // Se a resposta tem success e data como Map
      if (json['success'] == true &&
          json['data'] != null &&
          json['data'] is Map<String, dynamic>) {
        print('DashboardApiResponse: Processando com estrutura success/data');
        final dataMap = json['data'] as Map<String, dynamic>;
        print('DashboardApiResponse: Data keys: ${dataMap.keys.toList()}');

        // Se dentro de data tem outra estrutura success/data (resposta aninhada)
        if (dataMap.containsKey('success') &&
            dataMap.containsKey('data') &&
            dataMap['data'] is Map<String, dynamic>) {
          print(
            'DashboardApiResponse: Detectada estrutura aninhada, usando data.data',
          );
          final actualData = dataMap['data'] as Map<String, dynamic>;
          print(
            'DashboardApiResponse: Actual data keys: ${actualData.keys.toList()}',
          );
          return DashboardApiResponse(
            success: true,
            message: json['message'] ?? 'Sucesso',
            data: DashboardModel.fromJson(actualData),
          );
        }

        // Senão, usar dataMap diretamente
        return DashboardApiResponse(
          success: true,
          message: json['message'] ?? 'Sucesso',
          data: DashboardModel.fromJson(dataMap),
        );
      }

      // Se os dados estão diretamente no JSON (sem wrapper success/data)
      if (json['stockInfo'] != null || json['ordersByPeriod'] != null) {
        print('DashboardApiResponse: Processando dados diretos');
        return DashboardApiResponse(
          success: true,
          message: 'Dados recebidos com sucesso',
          data: DashboardModel.fromJson(json),
        );
      }

      // Caso contrário, é um erro
      print('DashboardApiResponse: Estrutura não reconhecida');
      return DashboardApiResponse(
        success: false,
        message: json['message'] ?? 'Estrutura de dados não reconhecida',
        data: null,
      );
    } catch (e) {
      print('DashboardApiResponse: Erro ao processar JSON: $e');
      print('DashboardApiResponse: Stack trace: ${StackTrace.current}');
      return DashboardApiResponse(
        success: false,
        message: 'Erro ao processar resposta da API: $e',
        data: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}
