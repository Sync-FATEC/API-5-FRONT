import '../../data/models/merchandise_model.dart' hide MerchandiseTypeModel;
import '../../data/models/merchandise_type_model.dart';
import 'http_client.dart';

class MerchandiseService {
  // Não precisamos mais do baseUrl pois o HttpClient já tem configurado

  Future<List<MerchandiseModel>> fetchMerchandiseList() async {
    final response = await HttpClient.get('/merchandise');
    if (response.success && response.data != null) {
      final List data = response.data!['data'] ?? response.data ?? [];
      return data.map((json) => MerchandiseModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message);
    }
  }

  Future<MerchandiseModel> fetchMerchandiseById(String id) async {
    final response = await HttpClient.get('/merchandise/$id');
    if (response.success && response.data != null) {
      return MerchandiseModel.fromJson(response.data!);
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> createMerchandise(MerchandiseModel merchandise) async {
    final response = await HttpClient.post(
      '/merchandise',
      body: merchandise.toJson(),
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> updateMerchandise(MerchandiseModel merchandise) async {
    final response = await HttpClient.put(
      '/merchandise/${merchandise.id}',
      body: merchandise.toJson(),
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  // Métodos para MerchandiseTypeModel
  Future<List<MerchandiseTypeModel>> fetchMerchandiseTypeList() async {
    final response = await HttpClient.get('/merchandise-types');
    if (response.success && response.data != null) {
      final List data = response.data!['data'] ?? response.data ?? [];
      return data.map((json) => MerchandiseTypeModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message);
    }
  }

  Future<MerchandiseTypeModel> fetchMerchandiseTypeById(String id) async {
    final response = await HttpClient.get('/merchandise-types/$id');
    if (response.success && response.data != null) {
      return MerchandiseTypeModel.fromJson(response.data!);
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> createMerchandiseType(MerchandiseTypeModel type) async {
    final response = await HttpClient.post(
      '/merchandise-types',
      body: type.toJson(),
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> updateMerchandiseType(MerchandiseTypeModel type) async {
    final response = await HttpClient.put(
      '/merchandise-types/${type.id}',
      body: type.toJson(),
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
