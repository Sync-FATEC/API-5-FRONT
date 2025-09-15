// lib/core/services/http_client.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpClient {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Headers padrão
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET Request
  static Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http
          .get(
            uri,
            headers: {..._defaultHeaders, ...?headers},
          )
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
      final response = await http
          .post(
            uri,
            headers: {..._defaultHeaders, ...?headers},
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
      final response = await http
          .put(
            uri,
            headers: {..._defaultHeaders, ...?headers},
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
      final response = await http
          .delete(
            uri,
            headers: {..._defaultHeaders, ...?headers},
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
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
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