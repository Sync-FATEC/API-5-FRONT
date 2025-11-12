// lib/core/services/exam_service.dart

import '../../data/models/exam_type_model.dart';
import 'http_client.dart';

/// Serviço de comunicação com rotas de Tipos de Exame
class ExamService {
  Future<List<ExamTypeModel>> fetchExamTypes({String? query, bool? isActive}) async {
    final params = <String, dynamic>{};
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (isActive != null) params['isActive'] = isActive;

    final response = await HttpClient.get('/exam-types', queryParams: params);
    if (response.success && response.data != null) {
      final List data = response.data!['data'] ?? response.data ?? [];
      return data.map((json) => ExamTypeModel.fromJson(json)).toList();
    }
    throw Exception(response.message);
  }

  Future<ExamTypeModel> createExamType(ExamTypeModel model) async {
    final response = await HttpClient.post('/exam-types', body: model.toJson());
    if (response.success && response.data != null) {
      final Map<String, dynamic> created = response.data!['data'] ?? response.data!;
      return ExamTypeModel.fromJson(created);
    }
    throw Exception(response.message);
  }

  Future<ExamTypeModel> updateExamType(String id, Map<String, dynamic> fields) async {
    final response = await HttpClient.patch('/exam-types/$id', body: fields);
    if (response.success && response.data != null) {
      final Map<String, dynamic> updated = response.data!['data'] ?? response.data!;
      return ExamTypeModel.fromJson(updated);
    }
    throw Exception(response.message);
  }

  Future<void> deleteExamType(String id) async {
    final response = await HttpClient.delete('/exam-types/$id');
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}