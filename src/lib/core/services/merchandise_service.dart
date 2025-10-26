import '../../data/models/merchandise_model.dart' hide MerchandiseTypeModel;
import '../../data/models/merchandise_type_model.dart';
import '../../data/models/merchandise_entry_model.dart';
import '../../data/models/merchandise_detail_response_model.dart';
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

  // Atualizar quantidade total do tipo de mercadoria (apenas para administradores)
  Future<void> updateQuantityTotal(String typeId, int quantityTotal) async {
    final response = await HttpClient.patch(
      '/merchandise-types/$typeId/quantity-total',
      body: {'quantityTotal': quantityTotal},
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  // Método para criar entrada de mercadoria via QR code ou manual
  Future<void> createMerchandiseEntry(MerchandiseEntryModel entry) async {
    print('MerchandiseService: Fazendo chamada para POST /merchandise');
    print('MerchandiseService: Dados da entrada: ${entry.toJson()}');
    
    try {
      final response = await HttpClient.post(
        '/merchandise',
        body: entry.toJson(),
      );

      if (response.success) {
        print('MerchandiseService: Entrada de mercadoria criada com sucesso');
        return;
      } else {
        print('MerchandiseService: Erro na resposta: ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('MerchandiseService: Erro na chamada: $e');
      throw Exception('Erro ao criar entrada de mercadoria: $e');
    }
  }

  // Buscar detalhes de mercadoria com entradas
  Future<MerchandiseDetailResponseModel> fetchMerchandiseTypeDetails(String id) async {
    print('📡 [MERCHANDISE_SERVICE] Buscando detalhes da mercadoria: $id');
    
    final response = await HttpClient.get('/merchandise-types/$id/merchandises');
    
    print('📡 [MERCHANDISE_SERVICE] Resposta recebida:');
    print('   - Success: ${response.success}');
    print('   - Message: ${response.message}');
    print('   - Data: ${response.data}');
    
    if (response.success && response.data != null) {
      final data = response.data!['data'];
      
      print('📦 [MERCHANDISE_SERVICE] Dados extraídos da resposta:');
      print('   - Tipo dos dados: ${data.runtimeType}');
      
      final merchandiseDetails = MerchandiseDetailResponseModel.fromJson(data);
      
      print('✅ [MERCHANDISE_SERVICE] Detalhes convertidos:');
      print('   - Mercadoria: ${merchandiseDetails.merchandiseType.name}');
      print('   - Entradas: ${merchandiseDetails.merchandises.length}');
      
      return merchandiseDetails;
    } else {
      print('❌ [MERCHANDISE_SERVICE] Erro na resposta: ${response.message}');
      throw Exception(response.message);
    }
  }
}
