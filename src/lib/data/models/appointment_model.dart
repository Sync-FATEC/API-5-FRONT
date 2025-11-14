// lib/data/models/appointment_model.dart

import '../enums/appointment_enums.dart';

/// Modelo de Agendamento conforme documentação da API.
/// Campos originais (JSON):
/// - id, pacienteId, examTypeId, dataHora, status, observacoes
class AppointmentModel {
  final String? id;
  final String patientId; // mapeia para 'pacienteId'
  final String examTypeId; // mapeia para 'examTypeId'
  final DateTime dateTime; // mapeia para 'dataHora'
  final AppointmentStatus status; // mapeia para 'status'
  final String? notes; // mapeia para 'observacoes'
  final DateTime? withdrawalDate; // mapeia para 'dataRetirada'

  const AppointmentModel({
    this.id,
    required this.patientId,
    required this.examTypeId,
    required this.dateTime,
    this.status = AppointmentStatus.agendado,
    this.notes,
    this.withdrawalDate,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dataHora'] ?? json['dateTime'];
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(rawDate.toString());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return AppointmentModel(
      id: json['id']?.toString(),
      patientId: (json['pacienteId'] ?? json['patientId'] ?? '').toString(),
      examTypeId: (json['examTypeId'] ?? '').toString(),
      dateTime: parsedDate.toUtc(),
      status: appointmentStatusFromString(json['status']?.toString()),
      notes: (json['observacoes'] ?? json['notes'])?.toString(),
      withdrawalDate: (() {
        final raw = json['dataRetirada'];
        if (raw == null) return null;
        try {
          return DateTime.parse(raw.toString()).toUtc();
        } catch (_) {
          return null;
        }
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'pacienteId': patientId,
      'examTypeId': examTypeId,
      'dataHora': dateTime.toIso8601String(),
      'status': appointmentStatusToString(status),
      'observacoes': notes,
    };
    if (withdrawalDate != null) {
      map['dataRetirada'] = withdrawalDate!.toIso8601String();
    }
    return map;
  }

  // Validações de dados
  bool get isValidIds => patientId.isNotEmpty && examTypeId.isNotEmpty;
  bool get isFutureDate => dateTime.isAfter(DateTime.now());
}