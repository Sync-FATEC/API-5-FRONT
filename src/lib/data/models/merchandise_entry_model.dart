class MerchandiseEntryModel {
  final String? id;
  final String recordNumber;
  final int quantity;
  final String status;
  final DateTime validDate;

  MerchandiseEntryModel({
    this.id,
    required this.recordNumber,
    required this.quantity,
    required this.status,
    required this.validDate,
  });

  factory MerchandiseEntryModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseEntryModel(
      id: json['id'],
      recordNumber: json['recordNumber'],
      quantity: json['quantity'],
      status: json['status'],
      validDate: DateTime.parse(json['validDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordNumber': recordNumber,
      'quantity': quantity,
      'status': status,
      'validDate': validDate.toIso8601String(),
    };
  }
}