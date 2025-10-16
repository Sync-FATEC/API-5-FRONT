class MerchandiseLog {
  final String id;
  final DateTime dateCreated;
  final String fieldModified;
  final String oldValue;
  final String newValue;
  final String? justification;
  final LogUser user;
  final LogMerchandiseType merchandiseType;

  MerchandiseLog({
    required this.id,
    required this.dateCreated,
    required this.fieldModified,
    required this.oldValue,
    required this.newValue,
    this.justification,
    required this.user,
    required this.merchandiseType,
  });

  factory MerchandiseLog.fromJson(Map<String, dynamic> json) {
    return MerchandiseLog(
      id: json['id'] ?? '',
      dateCreated: DateTime.parse(json['dateCreated']),
      fieldModified: json['fieldModifed'] ?? json['fieldModified'] ?? '',
      oldValue: json['oldValue']?.toString() ?? '',
      newValue: json['newValue']?.toString() ?? '',
      justification: json['justification'],
      user: LogUser.fromJson(json['user']),
      merchandiseType: LogMerchandiseType.fromJson(json['merchandiseType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateCreated': dateCreated.toIso8601String(),
      'fieldModified': fieldModified,
      'oldValue': oldValue,
      'newValue': newValue,
      'justification': justification,
      'user': user.toJson(),
      'merchandiseType': merchandiseType.toJson(),
    };
  }

  // Método para obter o nome do campo em português
  String get fieldDisplayName {
    switch (fieldModified.toLowerCase()) {
      case 'name':
        return 'Nome do produto';
      case 'recordnumber':
        return 'Número da ficha';
      case 'unitofmeasure':
        return 'Unidade de medida';
      case 'controlled':
        return 'Controlado';
      case 'minimumstock':
        return 'Estoque mínimo';
      case 'quantitytotal':
        return 'Quantidade';
      default:
        return fieldModified;
    }
  }

  // Formatar valor booleano
  String formatValue(String value) {
    if (value.toLowerCase() == 'true') return 'Sim';
    if (value.toLowerCase() == 'false') return 'Não';
    return value;
  }
}

class LogUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final DateTime validUntil;
  final bool isActive;

  LogUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.validUntil,
    required this.isActive,
  });

  factory LogUser.fromJson(Map<String, dynamic> json) {
    return LogUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      validUntil: DateTime.parse(json['validUntil']),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class LogMerchandiseType {
  final String id;
  final String name;
  final String recordNumber;
  final String unitOfMeasure;
  final int quantityTotal;
  final bool controlled;
  final int minimumStock;
  final String stockId;

  LogMerchandiseType({
    required this.id,
    required this.name,
    required this.recordNumber,
    required this.unitOfMeasure,
    required this.quantityTotal,
    required this.controlled,
    required this.minimumStock,
    required this.stockId,
  });

  factory LogMerchandiseType.fromJson(Map<String, dynamic> json) {
    return LogMerchandiseType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      recordNumber: json['recordNumber'] ?? '',
      unitOfMeasure: json['unitOfMeasure'] ?? '',
      quantityTotal: json['quantityTotal'] ?? 0,
      controlled: json['controlled'] ?? false,
      minimumStock: json['minimumStock'] ?? 0,
      stockId: json['stockId'] ?? '',
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
      'stockId': stockId,
    };
  }
}

// Classe para agrupar logs por data e usuário
class GroupedLog {
  final DateTime date;
  final LogUser user;
  final List<MerchandiseLog> logs;

  GroupedLog({
    required this.date,
    required this.user,
    required this.logs,
  });

  // Formatar data para exibição
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);

    if (logDate == today) {
      return 'Hoje';
    } else if (logDate == yesterday) {
      return 'Ontem';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // Formatar hora
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
