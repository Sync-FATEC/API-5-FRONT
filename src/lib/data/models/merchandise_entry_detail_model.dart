import 'batch_model.dart';

class MerchandiseEntryDetailModel {
  final String id;
  final int quantity;
  final String status;
  final BatchModel batch;

  MerchandiseEntryDetailModel({
    required this.id,
    required this.quantity,
    required this.status,
    required this.batch,
  });

  factory MerchandiseEntryDetailModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseEntryDetailModel(
      id: json['id'],
      quantity: json['quantity'],
      status: json['status'],
      batch: BatchModel.fromJson(json['batch']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'status': status,
      'batch': batch.toJson(),
    };
  }
}