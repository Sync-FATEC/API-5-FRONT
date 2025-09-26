import 'package:flutter/foundation.dart';

import '../enums/merchandise_enums.dart';

class MerchandiseTypeModel {
    final String? id;
    final String name;
    final String recordNumber;
    final String unitOfMeasure;
    final bool controlled;
    final MerchandiseGroup group;
    final int minimumStock;

    MerchandiseTypeModel({
        this.id,
        required this.name,
        required this.recordNumber,
        required this.unitOfMeasure,
        required this.controlled,
        required this.group,
        required this.minimumStock,
    });

    factory MerchandiseTypeModel.fromJson(Map<String, dynamic> json) {
        return MerchandiseTypeModel(
            id: json['id'],
            name: json['name'],
            recordNumber: json['recordNumber'],
            unitOfMeasure: json['unitOfMeasure'],
            controlled: json['controlled'],
            group: merchandiseGroupFromString(json['group']),
            minimumStock: json['minimumStock'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'recordNumber': recordNumber,
            'unitOfMeasure': unitOfMeasure,
            'controlled': controlled,
            'group': describeEnum(group),
            'minimumStock': minimumStock,
        };
    }
}
