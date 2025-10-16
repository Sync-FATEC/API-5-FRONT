import 'package:api2025/core/services/http_client.dart';
import 'package:api2025/data/models/merchandise_log_model.dart';

class MerchandiseLogService {
  static final MerchandiseLogService _instance = MerchandiseLogService._internal();
  factory MerchandiseLogService() => _instance;
  MerchandiseLogService._internal();

  // Buscar logs de um merchandise type específico
  Future<List<MerchandiseLog>> getMerchandiseLogs(String merchandiseTypeId) async {
    print('MerchandiseLogService: Fazendo chamada para /merchandise-types/$merchandiseTypeId/logs');
    try {
      final response = await HttpClient.get('/merchandise-types/$merchandiseTypeId/logs');

      if (response.success && response.data != null) {
        // A resposta pode vir em diferentes formatos
        final List<dynamic> logsData;
        
        if (response.data!['data'] != null) {
          logsData = response.data!['data'] as List<dynamic>;
        } else if (response.data!['logs'] != null) {
          logsData = response.data!['logs'] as List<dynamic>;
        } else if (response.data is List) {
          logsData = response.data as List<dynamic>;
        } else {
          logsData = [];
        }

        print('MerchandiseLogService: Logs encontrados: ${logsData.length}');
        
        final logs = logsData.map((log) => MerchandiseLog.fromJson(log)).toList();
        
        // Ordenar por data (mais recente primeiro)
        logs.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        
        return logs;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('MerchandiseLogService: Erro na chamada: $e');
      throw Exception('Erro ao buscar logs: $e');
    }
  }

  // Agrupar logs por data e usuário
  List<GroupedLog> groupLogsByDateAndUser(List<MerchandiseLog> logs) {
    Map<String, GroupedLog> groupedMap = {};

    for (var log in logs) {
      // Criar chave única para cada combinação de data e usuário
      final dateKey = DateTime(
        log.dateCreated.year,
        log.dateCreated.month,
        log.dateCreated.day,
        log.dateCreated.hour,
        log.dateCreated.minute,
      );
      
      final key = '${dateKey.toIso8601String()}_${log.user.id}';

      if (groupedMap.containsKey(key)) {
        groupedMap[key]!.logs.add(log);
      } else {
        groupedMap[key] = GroupedLog(
          date: dateKey,
          user: log.user,
          logs: [log],
        );
      }
    }

    // Converter para lista e ordenar por data (mais recente primeiro)
    final groupedList = groupedMap.values.toList();
    groupedList.sort((a, b) => b.date.compareTo(a.date));

    return groupedList;
  }
}
