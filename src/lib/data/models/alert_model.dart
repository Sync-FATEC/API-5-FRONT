class Alert {
  final String id;
  final String merchandiseName;
  final String merchandiseId;
  final int currentStock;
  final int minimumStock;
  final String alertType; // 'critical', 'warning', 'low'
  final String sectionName;
  final String sectionId;
  final DateTime lastUpdated;

  Alert({
    required this.id,
    required this.merchandiseName,
    required this.merchandiseId,
    required this.currentStock,
    required this.minimumStock,
    required this.alertType,
    required this.sectionName,
    required this.sectionId,
    required this.lastUpdated,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['typeId'] ?? json['id'] ?? '',
      merchandiseName: json['typeName'] ?? json['merchandiseName'] ?? '',
      merchandiseId: json['typeId'] ?? json['merchandiseId'] ?? '',
      currentStock: json['totalQuantity'] ?? json['currentStock'] ?? 0,
      minimumStock: json['minimumStock'] ?? 0,
      alertType: json['alertType'] ?? 'low',
      sectionName: json['sectionName'] ?? 'Seção não informada',
      sectionId: json['sectionId'] ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchandiseName': merchandiseName,
      'merchandiseId': merchandiseId,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'alertType': alertType,
      'sectionName': sectionName,
      'sectionId': sectionId,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Getter para calcular porcentagem de estoque restante
  double get stockPercentage {
    if (minimumStock <= 0) return 100.0;
    return (currentStock / minimumStock) * 100;
  }

  // Getter para determinar se é crítico
  bool get isCritical => alertType == 'critical';
  bool get isWarning => alertType == 'warning';
  bool get isLow => alertType == 'low';
}
