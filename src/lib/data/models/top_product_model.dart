class TopProduct {
  final String merchandiseTypeId;
  final String name;
  final int totalQuantity;
  final int orderCount;

  TopProduct({
    required this.merchandiseTypeId,
    required this.name,
    required this.totalQuantity,
    required this.orderCount,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      merchandiseTypeId: json['merchandiseTypeId'] ?? '',
      name: json['name'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchandiseTypeId': merchandiseTypeId,
      'name': name,
      'totalQuantity': totalQuantity,
      'orderCount': orderCount,
    };
  }
}
