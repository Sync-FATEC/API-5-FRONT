import 'package:api2025/core/services/http_client.dart';

class OrderService {
  static Future<bool> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    try {
      print("Atualizando pedido $orderId");
      final response = await HttpClient.put('/orders/$orderId', body: orderData);
      
      if (response.success) {
        print("Pedido $orderId atualizado com sucesso");
        return true;
      } else {
        print("Erro ao atualizar pedido: ${response.message}");
        return false;
      }
    } catch (e) {
      print("Exceção ao atualizar pedido: $e");
      return false;
    }
  }

  static Future<bool> deleteOrder(String orderId) async {
    try {
      print("Excluindo pedido $orderId");
      final response = await HttpClient.delete('/orders/$orderId');
      
      if (response.success) {
        print("Pedido $orderId excluído com sucesso");
        return true;
      } else {
        print("Erro ao excluir pedido: ${response.message}");
        return false;
      }
    } catch (e) {
      print("Exceção ao excluir pedido: $e");
      return false;
    }
  }

  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      print("Alterando status do pedido $orderId para $status");
      final response = await HttpClient.patch('/orders/$orderId/status', body: {
        'status': status,
      });
      
      if (response.success) {
        print("Status do pedido $orderId alterado com sucesso para $status");
        return true;
      } else {
        print("Erro ao alterar status do pedido: ${response.message}");
        return false;
      }
    } catch (e) {
      print("Exceção ao alterar status do pedido: $e");
      return false;
    }
  }
}