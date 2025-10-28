class OrdersBySection {
  final String sectionId;
  final String sectionName;
  final int orderCount;

  OrdersBySection({
    required this.sectionId,
    required this.sectionName,
    required this.orderCount,
  });

  factory OrdersBySection.fromJson(Map<String, dynamic> json) {
    return OrdersBySection(
      sectionId: json['sectionId'] ?? '',
      sectionName: json['sectionName'] ?? '',
      orderCount: json['orderCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'sectionName': sectionName,
      'orderCount': orderCount,
    };
  }
}
