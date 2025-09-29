import '../enums/merchandise_enums.dart';

class MerchandiseTypeModel {
    final String? id;
    final String name;
    final String recordNumber;
    final String unitOfMeasure;
    final int quantityTotal;
    final bool controlled;
    final MerchandiseGroup? group;
    final int minimumStock;
    final String? stockId;

    MerchandiseTypeModel({
        this.id,
        required this.name,
        required this.recordNumber,
        required this.unitOfMeasure,
        required this.quantityTotal,
        required this.controlled,
        this.group,
        required this.minimumStock,
        this.stockId,
    });

    factory MerchandiseTypeModel.fromJson(Map<String, dynamic> json) {
        return MerchandiseTypeModel(
            id: json['id'],
            name: json['name'],
            recordNumber: json['recordNumber'],
            unitOfMeasure: json['unitOfMeasure'],
            quantityTotal: json['quantityTotal'] ?? 0,
            controlled: json['controlled'],
            group: json['group'] != null ? merchandiseGroupFromString(json['group']) : null,
            minimumStock: json['minimumStock'],
            stockId: json['stockId'],
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
            'group': group != null ? merchandiseGroupToString(group!) : null,
            'minimumStock': minimumStock,
            'stockId': stockId,
        };
    }
}
