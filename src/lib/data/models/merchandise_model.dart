import 'package:flutter/foundation.dart';
import '../enums/merchandise_enums.dart';
import '../enums/merchandise_enums.dart';

class MerchandiseModel {
    final String? id;
    final String name;
    final List<MerchandiseTypeModel> types;
    final MerchandiseStatus status;

    MerchandiseModel({
        this.id,
        required this.name,
        required this.types,
        required this.status,
    });

    factory MerchandiseModel.fromJson(Map<String, dynamic> json) {
        return MerchandiseModel(
            id: json['id'],
            name: json['name'],
            types: (json['types'] as List)
                    .map((typeJson) => MerchandiseTypeModel.fromJson(typeJson))
                    .toList(),
            status: merchandiseStatusFromString(json['status']),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'types': types.map((type) => type.toJson()).toList(),
            'status': describeEnum(status),
        };
    }
}

class MerchandiseTypeModel {
    final String? id;
    final String typeId;
    final int quantity;
    final MerchandiseStatus status;

    MerchandiseTypeModel({
        this.id,
        required this.typeId,
        required this.quantity,
        required this.status,
    });

    factory MerchandiseTypeModel.fromJson(Map<String, dynamic> json) {
        return MerchandiseTypeModel(
            id: json['id'],
            typeId: json['typeId'],
            quantity: json['quantity'],
            status: merchandiseStatusFromString(json['status']),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'typeId': typeId,
            'quantity': quantity,
            'status': describeEnum(status),
        };
    }
}
