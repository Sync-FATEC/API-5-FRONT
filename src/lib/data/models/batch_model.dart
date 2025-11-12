class BatchModel {
  final String id;
  final DateTime expirationDate;

  BatchModel({
    required this.id,
    required this.expirationDate,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      expirationDate: DateTime.parse(json['expirationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expirationDate': expirationDate.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
    };
  }
}