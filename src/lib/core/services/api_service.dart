// lib/core/services/api_service.dart

import 'dart:convert';
import 'http_client.dart';
import '../../data/responses/user_api_response.dart';
import '../../data/responses/stock_api_response.dart';
import '../../data/responses/section_api_response.dart';
import '../../data/responses/dashboard_api_response.dart';
import '../../data/models/user_model.dart';

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
  Future<SectionApiResponse?> updateSection(
    String sectionId,
    String name,
  ) async {
    print(
      'ApiService: Fazendo chamada para PUT /sections/$sectionId - Nome: $name',
    );
    try {
      final response = await HttpClient.put(
        '/sections/$sectionId',
        body: {'name': name},
      );

      if (response.success && response.data != null) {
        final formattedResponse = {
          'success': true,
          'message': 'Seção atualizada com sucesso',
          'data': [
            response.data,
          ], // Envolvendo em array para manter consistência
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

  // Criar novo usuário
  Future<UserApiResponse?> createUser(
    String name,
    String email,
    String role,
  ) async {
    print(
      'ApiService: Fazendo chamada para /auth/register - Nome: $name, Email: $email, Role: $role',
    );
    try {
      final response = await HttpClient.post(
        '/auth/register',
        body: {'name': name, 'email': email, 'role': role},
      );

      if (response.success && response.data != null) {
        return UserApiResponse.fromJson(response.data!);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  // Listar todos os usuários
  Future<List<UserModel>> getAllUsers() async {
    print('ApiService: Fazendo chamada para /auth/users');
    try {
      final response = await HttpClient.get('/auth/users');
      print('ApiService: Response success: ${response.success}');
      print('ApiService: Response data: ${response.data}');

      if (response.success && response.data != null) {
        // A resposta vem como {data: {users: [...]}}
        final Map<String, dynamic> responseData = response.data!['data'] ?? {};
        final List<dynamic> usersData = responseData['users'] ?? [];
        print('ApiService: Users data length: ${usersData.length}');
        print('ApiService: Users data: $usersData');

        final userList = usersData
            .map((user) => UserModel.fromJson(user))
            .toList();
        print('ApiService: Mapped users count: ${userList.length}');
        return userList;
      } else {
        print(
          'ApiService: Response failed - success: ${response.success}, message: ${response.message}',
        );
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');

      // Se a rota não existe, retorna lista vazia por enquanto
      String errorString = e.toString();
      if (errorString.contains('Cannot GET /auth/users') ||
          errorString.contains('404') ||
          errorString.contains('<!DOCTYPE html>')) {
        print('ApiService: Rota /auth/users não implementada no backend ainda');
        throw Exception(
          'A funcionalidade de listagem de usuários ainda não está disponível no backend. Por favor, implemente as rotas necessárias primeiro.',
        );
      }

      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  // Atualizar usuário
  Future<UserApiResponse?> updateUser(
    String userId,
    String name,
    String email,
    String role,
    bool isActive,
  ) async {
    print('ApiService: Fazendo chamada para PUT /auth/users/$userId');
    try {
      final response = await HttpClient.put(
        '/auth/users/$userId',
        body: {
          'name': name,
          'email': email,
          'role': role,
          'isActive': isActive,
        },
      );

      if (response.success && response.data != null) {
        return UserApiResponse.fromJson(response.data!);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  // Deletar usuário
  Future<bool> deleteUser(String userId) async {
    print('ApiService: Fazendo chamada para DELETE /auth/users/$userId');
    try {
      final response = await HttpClient.delete('/auth/users/$userId');

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  // Vincular usuário a estoque
  Future<bool> linkUserToStock(
    String userId,
    String stockId,
    String responsibility,
  ) async {
    print('ApiService: Fazendo chamada para POST /auth/users/$userId/stocks');
    try {
      final response = await HttpClient.post(
        '/auth/users/$userId/stocks',
        body: {'stockId': stockId, 'responsibility': responsibility},
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao vincular usuário ao estoque: $e');
    }
  }

  // Desvincular usuário de estoque
  Future<bool> unlinkUserFromStock(String userId, String stockId) async {
    print(
      'ApiService: Fazendo chamada para DELETE /auth/users/$userId/stocks/$stockId',
    );
    try {
      final response = await HttpClient.delete(
        '/auth/users/$userId/stocks/$stockId',
      );

      if (response.success) {
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao desvincular usuário do estoque: $e');
    }
  }

  // Buscar estoques vinculados ao usuário
  Future<List<dynamic>> getUserStocks(String userId) async {
    print('ApiService: Fazendo chamada para /auth/users/$userId/stocks');
    try {
      final response = await HttpClient.get('/auth/users/$userId/stocks');

      print('ApiService: Response success: ${response.success}');
      print('ApiService: Response data: ${response.data}');

      if (response.success && response.data != null) {
        // O backend retorna { data: { stocks: [...] } }
        final Map<String, dynamic> responseData = response.data!['data'] ?? {};
        final List<dynamic> stocks = responseData['stocks'] ?? [];
        print('ApiService: Stocks encontrados: ${stocks.length}');
        print('ApiService: Stocks data: $stocks');
        return stocks;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro na chamada: $e');
      throw Exception('Erro ao buscar estoques do usuário: $e');
    }
  }

  // Buscar dashboard completo
  Future<DashboardApiResponse?> getCompleteDashboard({
    required String stockId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool includeOrders = true,
    bool includeMerchandise = true,
    bool includeStock = true,
  }) async {
    try {
      // Construir query parameters
      final Map<String, String> queryParams = {
        'stockId': stockId,
        'includeOrders': includeOrders.toString(),
        'includeMerchandise': includeMerchandise.toString(),
        'includeStock': includeStock.toString(),
      };

      if (period != null) {
        queryParams['period'] = period;
      }

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      // Construir URL com query string
      final queryString = queryParams.entries
          .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
          .join('&');

      final url = '/reports/dashboard/complete?$queryString';

      print('ApiService: Fazendo chamada para: $url');
      print('ApiService: Parâmetros: $queryParams');

      final response = await HttpClient.get(url);

      print('ApiService: Response success: ${response.success}');
      print('ApiService: Response message: ${response.message}');
      print('ApiService: Response data type: ${response.data.runtimeType}');
      print('ApiService: Response data: ${response.data}');

      if (response.success && response.data != null) {
        print('ApiService: Dashboard recebido com sucesso');

        // A resposta já vem como Map<String, dynamic> do HttpClient
        // Vamos usar diretamente os dados recebidos
        final responseData = response.data!;

        print('ApiService: Chaves disponíveis: ${responseData.keys.toList()}');

        // Criar uma resposta estruturada para o DashboardApiResponse
        final dashboardResponse = {
          'success': true,
          'message': 'Dashboard carregado com sucesso',
          'data': responseData, // Os dados já estão no formato correto
        };

        return DashboardApiResponse.fromJson(dashboardResponse);
      } else {
        print('ApiService: Erro na resposta - ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro detalhado na chamada: $e');
      print('ApiService: Tipo do erro: ${e.runtimeType}');
      throw Exception('Erro ao buscar dashboard completo: $e');
    }
  }

  // Download relatório completo em PDF
  Future<List<int>?> downloadCompleteReportPDF({
    required String stockId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool includeOrders = true,
    bool includeMerchandise = true,
    bool includeStock = true,
  }) async {
    try {
      // Construir query parameters
      final Map<String, String> queryParams = {
        'format': 'pdf',
        'stockId': stockId,
        'includeOrders': includeOrders.toString(),
        'includeMerchandise': includeMerchandise.toString(),
        'includeStock': includeStock.toString(),
      };

      if (period != null) {
        queryParams['period'] = period;
      }

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      print(
        'ApiService: Baixando PDF para: /reports/dashboard/complete/report?$queryString',
      );

      final response = await HttpClient.getBytes(
        '/reports/dashboard/complete/report?$queryString',
      );

      if (response.success && response.data != null) {
        print(
          'ApiService: PDF baixado com sucesso - ${response.data!.length} bytes',
        );
        return response.data;
      } else {
        print('ApiService: Erro ao baixar PDF - ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro ao baixar PDF: $e');
      throw Exception('Erro ao baixar relatório PDF: $e');
    }
  }

  // Download relatório completo em Excel
  Future<List<int>?> downloadCompleteReportExcel({
    required String stockId,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool includeOrders = true,
    bool includeMerchandise = true,
    bool includeStock = true,
  }) async {
    try {
      // Construir query parameters
      final Map<String, String> queryParams = {
        'format': 'excel',
        'stockId': stockId,
        'includeOrders': includeOrders.toString(),
        'includeMerchandise': includeMerchandise.toString(),
        'includeStock': includeStock.toString(),
        // Parâmetros de layout para Excel organizado
        'layout': 'compact',
        'groupSections': 'true',
      };

      if (period != null) {
        queryParams['period'] = period;
      }

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      print(
        'ApiService: Baixando Excel para: /reports/dashboard/complete/report?$queryString',
      );

      final response = await HttpClient.getBytes(
        '/reports/dashboard/complete/report?$queryString',
      );

      if (response.success && response.data != null) {
        print(
          'ApiService: Excel baixado com sucesso - ${response.data!.length} bytes',
        );
        return response.data;
      } else {
        print('ApiService: Erro ao baixar Excel - ${response.message}');
        throw Exception(response.message);
      }
    } catch (e) {
      print('ApiService: Erro ao baixar Excel: $e');
      throw Exception('Erro ao baixar relatório Excel: $e');
    }
  }
}
