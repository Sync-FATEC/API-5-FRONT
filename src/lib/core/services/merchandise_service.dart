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
  Future<List<MerchandiseTypeModel>> fetchMerchandiseTypeList({String? stockId}) async {
    
    final url = stockId != null ? '/merchandise-types/$stockId' : '/merchandise-types';
    final response = await HttpClient.get(url);
    
    print('📡 [MERCHANDISE_SERVICE] Resposta recebida:');
    print('   - Success: ${response.success}');
    print('   - Message: ${response.message}');
    print('   - Data: ${response.data}');
    
    if (response.success && response.data != null) {
      final List data = response.data!['data'] ?? response.data ?? [];
      
      print('📦 [MERCHANDISE_SERVICE] Dados extraídos da resposta:');
      print('   - Tipo dos dados: ${data.runtimeType}');
      print('   - Quantidade de itens: ${data.length}');
      
      if (data.isNotEmpty) {
        print('   - Primeiro item: ${data.first}');
      }
      
      final products = data.map((json) => MerchandiseTypeModel.fromJson(json)).toList();
      
      print('✅ [MERCHANDISE_SERVICE] Produtos convertidos:');
      for (var product in products) {
        print('   - ${product.name} (ID: ${product.id})');
      }
      
      return products;
    } else {
      print('❌ [MERCHANDISE_SERVICE] Erro na resposta: ${response.message}');
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

  Future<void> deleteMerchandiseType(String typeId) async {
    final response = await HttpClient.delete('/merchandise-types/$typeId');
    if (!response.success) {
      // Verificar se é erro de produto em uso
      String errorMessage = response.message.toLowerCase();
      if (errorMessage.contains('pedido') || 
          errorMessage.contains('order') || 
          errorMessage.contains('em uso') ||
          errorMessage.contains('in use') ||
          errorMessage.contains('constraint') ||
          errorMessage.contains('foreign key')) {
        throw Exception('Produto está sendo usado em pedidos');
      } else {
        throw Exception(response.message);
      }
    }
  }
}
