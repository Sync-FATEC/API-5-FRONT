import 'merchandise_type_model.dart';
import 'merchandise_entry_detail_model.dart';
import 'stock_model.dart';

class MerchandiseDetailResponseModel {
  final MerchandiseTypeDetailModel merchandiseType;
  final List<MerchandiseEntryDetailModel> merchandises;

  MerchandiseDetailResponseModel({
    required this.merchandiseType,
    required this.merchandises,
  });

  factory MerchandiseDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseDetailResponseModel(
      merchandiseType: MerchandiseTypeDetailModel.fromJson(json['merchandiseType']),
      merchandises: (json['merchandises'] as List)
          .map((merchandise) => MerchandiseEntryDetailModel.fromJson(merchandise))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchandiseType': merchandiseType.toJson(),
      'merchandises': merchandises.map((merchandise) => merchandise.toJson()).toList(),
    };
  }
}

class MerchandiseTypeDetailModel {
  final String id;
  final String name;
  final String recordNumber;
  final String unitOfMeasure;
  final int quantityTotal;
  final bool controlled;
  final int minimumStock;
  final String group;
  final StockModel stock;

  MerchandiseTypeDetailModel({
    required this.id,
    required this.name,
    required this.recordNumber,
    required this.unitOfMeasure,
    required this.quantityTotal,
    required this.controlled,
    required this.minimumStock,
    required this.group,
    required this.stock,
  });

  factory MerchandiseTypeDetailModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseTypeDetailModel(
      id: json['id'],
      name: json['name'],
      recordNumber: json['recordNumber'],
      unitOfMeasure: json['unitOfMeasure'],
      quantityTotal: json['quantityTotal'],
      controlled: json['controlled'],
      minimumStock: json['minimumStock'],
      group: json['group'],
      stock: StockModel.fromJson(json['stock']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'recordNumber': recordNumber,
      'unitOfMeasure': unitOfMeasure,
      'quantityTotal': quantityTotal,
      'controlled': controlled,
      'minimumStock': minimumStock,
      'group': group,
      'stock': stock.toJson(),
    };
  }
}