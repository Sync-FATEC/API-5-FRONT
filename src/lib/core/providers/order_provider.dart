import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:api2025/core/services/http_client.dart';
import 'package:api2025/core/services/order_service.dart';
import 'package:api2025/data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders({String? stockId}) async {
    print("Iniciando carregamento de pedidos${stockId != null ? ' para stock: $stockId' : ''}");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Usar o HttpClient que já gerencia o token de autenticação
      final endpoint = stockId != null ? '/orders/$stockId' : '/orders';
      print("Fazendo requisição para: $endpoint");
      final response = await HttpClient.get(endpoint);
      
      if (response.success) {
        try {
          // Decodificar a string da mensagem em uma lista JSON
          final List<dynamic> ordersJson = json.decode(response.message) as List;
          _orders = ordersJson.map((json) => Order.fromJson(json)).toList();
          if (_orders.isNotEmpty) {
            print("Pedidos carregados: ${_orders.length}");
          }
        } catch (e) {
          print("Erro ao processar resposta: $e");
          _errorMessage = 'Erro ao processar dados dos pedidos';
        }
      } else {
        print("Erro na resposta: ${response.message}");
        _errorMessage = 'Falha ao carregar pedidos: ${response.message}';
      }
    } catch (e) {
      print("Exceção capturada: $e");
      _errorMessage = 'Erro ao carregar pedidos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  // (Removido: chave extra que fechava a classe antes dos métodos auxiliares)
  }

  // Filtrar pedidos por status
  List<Order> getFilteredOrders(String filter) {
    if (filter == 'TODOS') {
      return _orders;
    } else if (filter == 'EM ABERTO') {
      return _orders.where((order) => order.status == 'PENDING').toList();
    } else if (filter == 'FINALIZADOS') {
      return _orders.where((order) => order.status == 'COMPLETED').toList();
    }
    return _orders;
  }

  // Buscar pedidos por texto
  List<Order> searchOrders(String query) {
    if (query.isEmpty) {
      return _orders;
    }

    return _orders.where((order) {
      return order.id.toLowerCase().contains(query.toLowerCase()) ||
          order.sectionName.toLowerCase().contains(query.toLowerCase()) ||
          order.orderItems.any((item) =>
              item.merchandiseName.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Criar novo pedido
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    print("Iniciando criação de pedido");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpClient.post('/orders', body: orderData);
      
      if (response.success) {
        print("Pedido criado com sucesso");
        // Recarregar a lista de pedidos após criar um novo
        await loadOrders();
        return true;
      } else {
        print("Erro ao criar pedido: ${response.message}");
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      print("Exceção ao criar pedido: $e");
      _errorMessage = 'Erro ao criar pedido';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar pedido
  Future<bool> updateOrder(String orderId, Map<String, dynamic> orderData, {String? stockId}) async {
    print("Iniciando atualização de pedido $orderId");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await OrderService.updateOrder(orderId, orderData);
      
      if (success) {
        print("Pedido $orderId atualizado com sucesso");
        // Recarregar a lista de pedidos após atualizar, mantendo o mesmo contexto de stockId
        await loadOrders(stockId: stockId);
        return true;
      } else {
        _errorMessage = 'Erro ao atualizar pedido';
        return false;
      }
    } catch (e) {
      print("Exceção ao atualizar pedido: $e");
      _errorMessage = 'Erro ao atualizar pedido';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Excluir pedido
  Future<bool> deleteOrder(String orderId, {String? stockId}) async {
    print("Iniciando exclusão de pedido $orderId");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await OrderService.deleteOrder(orderId);
      
      if (success) {
        print("Pedido $orderId excluído com sucesso");
        // Recarregar a lista de pedidos após excluir, mantendo o mesmo contexto de stockId
        await loadOrders(stockId: stockId);
        return true;
      } else {
        _errorMessage = 'Erro ao excluir pedido';
        return false;
      }
    } catch (e) {
      print("Exceção ao excluir pedido: $e");
      _errorMessage = 'Erro ao excluir pedido';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alterar status do pedido
  Future<bool> updateOrderStatus(String orderId, String status, {String? stockId}) async {
    print("Iniciando alteração de status do pedido $orderId para $status");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await OrderService.updateOrderStatus(orderId, status);
      
      if (success) {
        print("Status do pedido $orderId alterado com sucesso para $status");
        // Recarregar a lista de pedidos após alterar status, mantendo o mesmo contexto de stockId
        await loadOrders(stockId: stockId);
        return true;
      } else {
        _errorMessage = 'Erro ao alterar status do pedido';
        return false;
      }
    } catch (e) {
      print("Exceção ao alterar status do pedido: $e");
      _errorMessage = 'Erro ao alterar status do pedido';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos auxiliares

}
