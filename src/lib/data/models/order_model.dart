import 'package:api2025/data/models/order_item_model.dart';

class Order {
  final String id;
  final String creationDate;
  final String? withdrawalDate;
  final String status;
  final String sectionId;
  final String sectionName;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.creationDate,
    this.withdrawalDate,
    required this.status,
    required this.sectionId,
    required this.sectionName,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      creationDate: json['creationDate'] ?? '',
      withdrawalDate: json['withdrawalDate'],
      status: json['status'] ?? '',
      sectionId: json['sectionId'] ?? '',
      sectionName: json['sectionName'] ?? '',
      orderItems: (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationDate': creationDate,
      'withdrawalDate': withdrawalDate,
      'status': status,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}