// lib/core/services/appointment_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'http_client.dart';
import '../../data/models/appointment_model.dart';
import '../../data/enums/appointment_enums.dart';

/// Serviço de comunicação com rotas de Agendamentos
class AppointmentService {
  Future<List<AppointmentModel>> fetchAppointments({
    DateTime? start,
    DateTime? end,
    String? patientId,
    String? examTypeId,
    AppointmentStatus? status,
  }) async {
    final params = <String, dynamic>{};
    if (start != null) params['start'] = start.toUtc().toIso8601String();
    if (end != null) params['end'] = end.toUtc().toIso8601String();
    if (patientId != null && patientId.isNotEmpty) params['pacienteId'] = patientId;
    if (examTypeId != null && examTypeId.isNotEmpty) params['examTypeId'] = examTypeId;
    if (status != null) params['status'] = appointmentStatusToString(status);

    final response = await HttpClient.get('/appointments', queryParams: params);
    if (response.success && response.data != null) {
      final List data = response.data!['data'] ?? response.data ?? [];
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    }
    throw Exception(response.message);
  }

  Future<AppointmentModel> createAppointment(AppointmentModel model) async {
    final response = await HttpClient.post('/appointments', body: model.toJson());
    if (response.success && response.data != null) {
      final Map<String, dynamic> created = response.data!['data'] ?? response.data!;
      return AppointmentModel.fromJson(created);
    }
    throw Exception(response.message);
  }

  Future<AppointmentModel> updateAppointment(String id, Map<String, dynamic> fields) async {
    final response = await HttpClient.patch('/appointments/$id', body: fields);
    if (response.success && response.data != null) {
      final Map<String, dynamic> updated = response.data!['data'] ?? response.data!;
      return AppointmentModel.fromJson(updated);
    }
    throw Exception(response.message);
  }

  Future<void> cancelAppointment(String id) async {
    final response = await HttpClient.delete('/appointments/$id');
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  /// Baixa o PDF do recibo do agendamento e salva em [filePath]
  Future<File> downloadReceiptPdf(String appointmentId, String filePath) async {
    // Obter token para autenticação manual em chamada binária
    final token = await AuthService().getIdToken();
    final uri = Uri.parse('${HttpClient.baseUrl}/appointments/$appointmentId/receipt');
    final response = await http.get(uri, headers: {
      'Accept': 'application/pdf',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    }
    throw Exception('Falha ao baixar recibo: ${response.statusCode}');
  }

  /// Busca pacientes por nome/email (auxiliar ao agendamento)
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final params = {'q': query};
    final response = await HttpClient.get('/appointments/patients', queryParams: params);
    if (response.success && response.data != null) {
      final List data = response.data!['data'] ?? response.data ?? [];
      // Retorna a estrutura bruta para uso flexível na UI (id, nome, email)
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(response.message);
  }

  /// Relatório por período: total, por status e por tipo de exame
  Future<Map<String, dynamic>> getReport({required DateTime start, required DateTime end}) async {
    final params = {
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
    };
    final response = await HttpClient.get('/appointments/report', queryParams: params);
    if (response.success && response.data != null) {
      final Map<String, dynamic> data = response.data!['data'] ?? response.data!;
      return data;
    }
    throw Exception(response.message);
  }
}