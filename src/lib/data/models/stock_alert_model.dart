class StockAlert {
  final String merchandiseTypeId;
  final String name;
  final String status;
  final int inStock;
  final int minimumStock;

  StockAlert({
    required this.merchandiseTypeId,
    required this.name,
    required this.status,
    required this.inStock,
    required this.minimumStock,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      merchandiseTypeId: json['merchandiseTypeId'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      inStock: json['inStock'] ?? 0,
      minimumStock: json['minimumStock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchandiseTypeId': merchandiseTypeId,
      'name': name,
      'status': status,
      'inStock': inStock,
      'minimumStock': minimumStock,
    };
  }

  // Helper para determinar cores baseadas no status
  bool get isCritical =>
      status.toLowerCase() == 'crítico' || status.toLowerCase() == 'critical';
  bool get isLow =>
      status.toLowerCase() == 'baixo' || status.toLowerCase() == 'low';
  bool get isMedium =>
      status.toLowerCase() == 'médio' || status.toLowerCase() == 'medium';
}
