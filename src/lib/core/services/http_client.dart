// lib/core/services/http_client.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HttpClient {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Headers padrão
  static Future<Map<String, String>> get _defaultHeaders async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Adicionar token de autorização se disponível
    final authService = AuthService();
    final token = await authService.getIdToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // GET Request
  static Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final defaultHeaders = await _defaultHeaders;
      final response = await http
          .get(uri, headers: {...defaultHeaders, ...?headers})
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST Request
  static Future<HttpResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final defaultHeaders = await _defaultHeaders;
      final response = await http
          .post(
            uri,
            headers: {...defaultHeaders, ...?headers},
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT Request
  static Future<HttpResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final defaultHeaders = await _defaultHeaders;
      final response = await http
          .put(
            uri,
            headers: {...defaultHeaders, ...?headers},
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE Request
  static Future<HttpResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final defaultHeaders = await _defaultHeaders;
      final response = await http
          .delete(uri, headers: {...defaultHeaders, ...?headers})
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PATCH Request
  static Future<HttpResponse> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final defaultHeaders = await _defaultHeaders;
      final response = await http
          .patch(
            uri,
            headers: {...defaultHeaders, ...?headers},
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Construir URI
  static Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  // Tratar resposta
  static HttpResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    Map<String, dynamic>? data;
    try {
      data = body.isNotEmpty ? json.decode(body) : null;
    } catch (e) {
      data = {'message': body};
    }

    return HttpResponse(
      statusCode: statusCode,
      data: data,
      success: statusCode >= 200 && statusCode < 300,
      message: _getStatusMessage(statusCode, data),
    );
  }

  // Tratar erros
  static HttpResponse _handleError(dynamic error) {
    String message = 'Erro de conexão';

    if (error is SocketException) {
      message = 'Sem conexão com a internet';
    } else if (error is HttpException) {
      message = 'Erro HTTP: ${error.message}';
    } else if (error is FormatException) {
      message = 'Erro no formato da resposta';
    } else {
      message = 'Erro inesperado: $error';
    }

    return HttpResponse(
      statusCode: 0,
      data: null,
      success: false,
      message: message,
    );
  }

  // Obter mensagem de status
  static String _getStatusMessage(int statusCode, Map<String, dynamic>? data) {
    if (data != null && data.containsKey('message')) {
      return data['message'].toString();
    }

    switch (statusCode) {
      case 200:
        return 'Sucesso';
      case 201:
        return 'Criado com sucesso';
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Não encontrado';
      case 500:
        return 'Erro interno do servidor';
      default:
        return 'Erro desconhecido';
    }
  }

  // GET Request para baixar bytes (arquivos)
  static Future<HttpBytesResponse> getBytes(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final defaultHeaders = await _defaultHeaders;
      final response = await http
          .get(uri, headers: {...defaultHeaders, ...?headers})
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return HttpBytesResponse(
          statusCode: response.statusCode,
          data: response.bodyBytes,
          success: true,
          message: 'Arquivo baixado com sucesso',
        );
      } else {
        return HttpBytesResponse(
          statusCode: response.statusCode,
          data: null,
          success: false,
          message: 'Erro ao baixar arquivo: ${response.statusCode}',
        );
      }
    } catch (e) {
      return HttpBytesResponse(
        statusCode: 0,
        data: null,
        success: false,
        message: 'Erro ao baixar arquivo: $e',
      );
    }
  }
}

// Classe para resposta HTTP com bytes
class HttpBytesResponse {
  final int statusCode;
  final List<int>? data;
  final bool success;
  final String message;

  HttpBytesResponse({
    required this.statusCode,
    required this.data,
    required this.success,
    required this.message,
  });

  @override
  String toString() {
    return 'HttpBytesResponse(statusCode: $statusCode, success: $success, message: $message, dataLength: ${data?.length})';
  }
}

// Classe para resposta HTTP
class HttpResponse {
  final int statusCode;
  final Map<String, dynamic>? data;
  final bool success;
  final String message;

  HttpResponse({
    required this.statusCode,
    required this.data,
    required this.success,
    required this.message,
  });

  @override
  String toString() {
    return 'HttpResponse(statusCode: $statusCode, success: $success, message: $message, data: $data)';
  }
}
