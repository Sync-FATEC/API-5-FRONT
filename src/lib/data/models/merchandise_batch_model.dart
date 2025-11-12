class MerchandiseBatchModel {
  final String? id;
  final DateTime? expirationDate;

  MerchandiseBatchModel({
    this.id,
    this.expirationDate,
  });

  factory MerchandiseBatchModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseBatchModel(
      id: json['id'],
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }
}