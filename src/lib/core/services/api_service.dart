// lib/core/services/api_service.dart

import 'dart:convert';
import 'http_client.dart';
import '../../data/responses/user_api_response.dart';
import '../../data/responses/stock_api_response.dart';
import '../../data/responses/section_api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Buscar dados do usuário pela API
  Future<UserApiResponse?> getUserData(String email) async {
    print('ApiService: Fazendo chamada para /auth/user-data/$email');
    try {
      final response = await HttpClient.get('/auth/user-data/$email');

      if (response.success && response.data != null) {
        return UserApiResponse.fromJson(response.data!);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }

  // Buscar estoques do usuário pela API
  Future<StockApiResponse?> getStocks(String userId) async {
    print('ApiService: Fazendo chamada para /stocks/$userId');
    try {
      final response = await HttpClient.get('/stocks/$userId');

      if (response.success && response.data != null) {
        return StockApiResponse.fromJson(response.data!);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao buscar estoques: $e');
    }
  }

  // Criar novo estoque
  Future<StockApiResponse?> createStock(String name, String location) async {
    print(
      'ApiService: Fazendo chamada para /stocks/ - Nome: $name, Localização: $location',
    );
    try {
      final response = await HttpClient.post(
        '/stocks',
        body: {'name': name, 'location': location},
      );

      if (response.success && response.data != null) {
        return StockApiResponse.fromJson(response.data!);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao criar estoque: $e');
    }
  }

  // Excluir estoque
  Future<bool> deleteStock(String stockId) async {
    print('ApiService: Fazendo chamada para DELETE /stocks/$stockId');
    try {
      final response = await HttpClient.delete('/stocks/$stockId');

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao excluir estoque: $e');
    }
  }

  // Criar nova seção
  Future<SectionApiResponse?> createSection(String name) async {
    print('ApiService: Fazendo chamada para /sections - Nome: $name');
    try {
      final response = await HttpClient.post('/sections', body: {'name': name});

      if (response.success && response.data != null) {
        // Formatando a resposta para o padrão esperado
        final Map<String, dynamic> formattedResponse = {
          'success': true,
          'message': '',
          'data': [response.data],
        };
        return SectionApiResponse.fromJson(formattedResponse);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao criar seção: $e');
    }
  }

  // Buscar seções
  Future<SectionApiResponse?> getSections({String? stockId}) async {
    final url = stockId != null ? '/sections/$stockId' : '/sections';
    print('ApiService: Fazendo chamada para $url');
    try {
      final response = await HttpClient.get(url);

      if (response.success && response.data != null) {
        // Verificar se a resposta contém a chave 'message' com uma lista de seções
        if (response.data!.containsKey('message') &&
            response.data!['message'] is String) {
          // Se 'message' é uma string, tentar fazer parse como JSON
          try {
            final List<dynamic> sectionsJson = json.decode(
              response.data!['message'],
            );
            final Map<String, dynamic> formattedResponse = {
              'success': true,
              'message': '',
              'data': sectionsJson,
            };
            return SectionApiResponse.fromJson(formattedResponse);
          } catch (e) {
            print('ApiService: Erro ao fazer parse do JSON: $e');
            throw Exception('Erro ao processar dados de seções: $e');
          }
        } else {
          // Usar o formato original se 'message' já for uma lista
          final Map<String, dynamic> formattedResponse = {
            'success': true,
            'message': '',
            'data': response.data!['message'] is List
                ? response.data!['message']
                : [],
          };
          return SectionApiResponse.fromJson(formattedResponse);
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao buscar seções: $e');
    }
  }

  // Excluir seção
  Future<bool> deleteSection(String sectionId) async {
    print('ApiService: Fazendo chamada para DELETE /sections/$sectionId');
    try {
      final response = await HttpClient.delete('/sections/$sectionId');

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao excluir seção: $e');
    }
  }

  // Atualizar seção
  Future<SectionApiResponse?> updateSection(String sectionId, String name) async {
    print('ApiService: Fazendo chamada para PUT /sections/$sectionId - Nome: $name');
    try {
      final response = await HttpClient.put('/sections/$sectionId', body: {'name': name});

      if (response.success && response.data != null) {
        final formattedResponse = {
          'success': true,
          'message': 'Seção atualizada com sucesso',
          'data': [response.data], // Envolvendo em array para manter consistência
        };
        return SectionApiResponse.fromJson(formattedResponse);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao atualizar seção: $e');
    }
  }
}
