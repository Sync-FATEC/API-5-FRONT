import 'merchandise_batch_model.dart';

class MerchandiseWithBatchModel {
  final String? id;
  final int quantity;
  final String status;
  final MerchandiseBatchModel? batch;

  MerchandiseWithBatchModel({
    this.id,
    required this.quantity,
    required this.status,
    this.batch,
  });

  factory MerchandiseWithBatchModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseWithBatchModel(
      id: json['id'],
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? 'AVAILABLE',
      batch: json['batch'] != null 
          ? MerchandiseBatchModel.fromJson(json['batch'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'status': status,
      'batch': batch?.toJson(),
    };
  }
}