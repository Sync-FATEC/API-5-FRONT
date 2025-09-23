// lib/core/services/api_service.dart

import 'dart:convert';
import 'http_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Buscar dados do usuário pela API
  Future<UserApiResponse?> getUserData(String email) async {
    print('ApiService: Fazendo chamada para /auth/user-data/$email');
    try {
      final response = await HttpClient.get('/auth/user-data/$email');
      print('ApiService: Resposta recebida - Success: ${response.success}, Data: ${response.data}');
      
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
      print('ApiService: Resposta recebida - Success: ${response.success}, Data: ${response.data}');
      
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
    print('ApiService: Fazendo chamada para /stocks/ - Nome: $name, Localização: $location');
    try {
      final response = await HttpClient.post('/stocks', body: {
        'name': name,
        'location': location,
      });
      print('ApiService: Resposta recebida - Success: ${response.success}, Data: ${response.data}');
      
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
      print('ApiService: Resposta recebida - Success: ${response.success}, Message: ${response.message}');
      
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
      final response = await HttpClient.post('/sections', body: {
        'name': name,
      });
      print('ApiService: Resposta recebida - Success: ${response.success}, Data: ${response.data}');
      
      if (response.success && response.data != null) {
        // Formatando a resposta para o padrão esperado
        final Map<String, dynamic> formattedResponse = {
          'success': true,
          'message': '',
          'data': [response.data]
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
  Future<SectionApiResponse?> getSections() async {
    print('ApiService: Fazendo chamada para /sections');
    try {
      final response = await HttpClient.get('/sections');
      print('ApiService: Resposta recebida - Success: ${response.success}, Data: ${response.data}');
      
      if (response.success && response.data != null) {
        // Verificar se a resposta contém a chave 'message' com uma lista de seções
        if (response.data!.containsKey('message') && response.data!['message'] is String) {
          // Se 'message' é uma string, tentar fazer parse como JSON
          try {
            final List<dynamic> sectionsJson = json.decode(response.data!['message']);
            final Map<String, dynamic> formattedResponse = {
              'success': true,
              'message': '',
              'data': sectionsJson
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
                : []
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
      print('ApiService: Resposta recebida - Success: ${response.success}, Message: ${response.message}');
      
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
}

// Classe para representar a resposta da API
class UserApiResponse {
  final bool success;
  final UserData? data;
  final String message;

  UserApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory UserApiResponse.fromJson(Map<String, dynamic> json) {
    return UserApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

// Classe para representar os dados do usuário
class UserData {
  final String id;
  final String email;
  final String name;
  final String role;
  final String validUntil;
  final String createdAt;
  final bool isActive;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.validUntil,
    required this.createdAt,
    required this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      validUntil: json['validUntil'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'validUntil': validUntil,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}

// Classe para representar a resposta da API de estoques
class StockApiResponse {
  final bool success;
  final List<StockData> data;
  final String message;

  StockApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory StockApiResponse.fromJson(Map<String, dynamic> json) {
    return StockApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null 
          ? (json['data'] as List).map((item) => StockData.fromJson(item)).toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}

// Classe para representar os dados de um estoque
class StockData {
  final String id;
  final String name;
  final String location;
  final bool active;

  StockData({
    required this.id,
    required this.name,
    required this.location,
    required this.active,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'active': active,
    };
  }
}

// Classe para representar a resposta da API de seções
class SectionApiResponse {
  final bool success;
  final List<SectionData> data;
  final String message;

  SectionApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SectionApiResponse.fromJson(Map<String, dynamic> json) {
    return SectionApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null 
          ? (json['data'] as List).map((item) => SectionData.fromJson(item)).toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}

// Classe para representar os dados de uma seção
class SectionData {
  final String id;
  final String name;

  SectionData({
    required this.id,
    required this.name,
  });

  factory SectionData.fromJson(Map<String, dynamic> json) {
    return SectionData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}