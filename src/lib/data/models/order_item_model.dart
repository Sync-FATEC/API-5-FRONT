class OrderItem {
  final String id;
  final int quantity;
  final String merchandiseId;
  final String merchandiseName;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.merchandiseId,
    required this.merchandiseName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      quantity: json['quantity'] ?? 0,
      merchandiseId: json['merchandiseId'] ?? '',
      merchandiseName: json['merchandiseName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'merchandiseId': merchandiseId,
      'merchandiseName': merchandiseName,
    };
  }
}