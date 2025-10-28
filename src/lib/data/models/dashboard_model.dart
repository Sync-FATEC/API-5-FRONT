import 'order_model.dart';
import 'orders_by_section_model.dart';
import 'stock_alert_model.dart';
import 'top_product_model.dart';

class DashboardModel {
  final String stockId;
  final String stockName;
  final String stockLocation;
  final List<Order>? orders;
  final List<OrdersBySection>? ordersBySection;
  final List<StockAlert>? stockAlerts;
  final List<TopProduct>? topProducts;
  final Map<String, dynamic>? merchandise;
  final Map<String, dynamic>? stock;
  final DateTime startDate;
  final DateTime endDate;

  DashboardModel({
    required this.stockId,
    required this.stockName,
    required this.stockLocation,
    this.orders,
    this.ordersBySection,
    this.stockAlerts,
    this.topProducts,
    this.merchandise,
    this.stock,
    required this.startDate,
    required this.endDate,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    print(
      'DashboardModel.fromJson: Recebendo JSON keys: ${json.keys.toList()}',
    );

    List<Order>? ordersList;
    String stockName = '';
    String stockLocation = '';
    String stockId = '';

    // Extrair informações do estoque
    if (json['stockInfo'] != null) {
      final stockInfo = json['stockInfo'];
      stockId = stockInfo['id'] ?? '';
      stockName = stockInfo['name'] ?? '';
      stockLocation = stockInfo['location'] ?? '';
      print(
        'DashboardModel: StockInfo - ID: $stockId, Nome: $stockName, Local: $stockLocation',
      );
    }

    // Extrair pedidos
    if (json['ordersByPeriod'] != null &&
        json['ordersByPeriod']['orders'] != null) {
      try {
        final ordersData = json['ordersByPeriod']['orders'] as List;
        ordersList = ordersData
            .map(
              (orderJson) => Order.fromJson(orderJson as Map<String, dynamic>),
            )
            .toList();
        print(
          'DashboardModel: ${ordersList.length} pedidos carregados com sucesso',
        );
      } catch (e) {
        print('DashboardModel: Erro ao carregar pedidos: $e');
        ordersList = [];
      }
    } else {
      print('DashboardModel: ordersByPeriod não encontrado');
      ordersList = [];
    }

    // Extrair pedidos por seção
    List<OrdersBySection>? ordersBySectionList;
    if (json['ordersBySection'] != null) {
      try {
        final ordersBySectionData = json['ordersBySection'] as List;
        ordersBySectionList = ordersBySectionData
            .map(
              (sectionJson) =>
                  OrdersBySection.fromJson(sectionJson as Map<String, dynamic>),
            )
            .toList();
        print(
          'DashboardModel: ${ordersBySectionList.length} seções carregadas com sucesso',
        );
      } catch (e) {
        print('DashboardModel: Erro ao carregar pedidos por seção: $e');
        ordersBySectionList = [];
      }
    } else {
      print('DashboardModel: ordersBySection não encontrado');
      ordersBySectionList = [];
    }

    // Verificar tipos de merchandise e stock
    Map<String, dynamic>? merchandiseData;
    if (json['productStatus'] != null) {
      if (json['productStatus'] is Map<String, dynamic>) {
        merchandiseData = json['productStatus'] as Map<String, dynamic>;
      } else {
        print(
          'DashboardModel: productStatus não é Map, é ${json['productStatus'].runtimeType}',
        );
      }
    }

    // Extrair alertas de estoque
    List<StockAlert>? stockAlertsList;
    if (json['stockAlerts'] != null) {
      try {
        if (json['stockAlerts'] is List) {
          final stockAlertsData = json['stockAlerts'] as List;
          stockAlertsList = stockAlertsData
              .map(
                (alertJson) =>
                    StockAlert.fromJson(alertJson as Map<String, dynamic>),
              )
              .toList();
          print(
            'DashboardModel: ${stockAlertsList.length} alertas de estoque carregados com sucesso',
          );
        } else {
          print(
            'DashboardModel: stockAlerts não é List, é ${json['stockAlerts'].runtimeType}',
          );
          stockAlertsList = [];
        }
      } catch (e) {
        print('DashboardModel: Erro ao carregar alertas de estoque: $e');
        stockAlertsList = [];
      }
    } else {
      print('DashboardModel: stockAlerts não encontrado');
      stockAlertsList = [];
    }

    // Extrair top produtos
    List<TopProduct>? topProductsList;
    if (json['topProducts'] != null) {
      try {
        if (json['topProducts'] is List) {
          final topProductsData = json['topProducts'] as List;
          topProductsList = topProductsData
              .map(
                (productJson) =>
                    TopProduct.fromJson(productJson as Map<String, dynamic>),
              )
              .toList();
          print(
            'DashboardModel: ${topProductsList.length} top produtos carregados com sucesso',
          );
        } else {
          print(
            'DashboardModel: topProducts não é List, é ${json['topProducts'].runtimeType}',
          );
          topProductsList = [];
        }
      } catch (e) {
        print('DashboardModel: Erro ao carregar top produtos: $e');
        topProductsList = [];
      }
    } else {
      print('DashboardModel: topProducts não encontrado');
      topProductsList = [];
    }

    Map<String, dynamic>? stockData;

    final model = DashboardModel(
      stockId: stockId,
      stockName: stockName,
      stockLocation: stockLocation,
      orders: ordersList,
      ordersBySection: ordersBySectionList,
      stockAlerts: stockAlertsList,
      topProducts: topProductsList,
      merchandise: merchandiseData,
      stock: stockData,
      startDate: DateTime.now().subtract(const Duration(days: 30)), // Fallback
      endDate: DateTime.now(),
    );

    print(
      'DashboardModel: Modelo criado - StockName: ${model.stockName}, Orders: ${model.orders?.length}',
    );
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'stockId': stockId,
      'stockName': stockName,
      'stockLocation': stockLocation,
      'orders': orders?.map((order) => order.toJson()).toList(),
      'ordersBySection': ordersBySection
          ?.map((section) => section.toJson())
          .toList(),
      'stockAlerts': stockAlerts?.map((alert) => alert.toJson()).toList(),
      'topProducts': topProducts?.map((product) => product.toJson()).toList(),
      'merchandise': merchandise,
      'stock': stock,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
