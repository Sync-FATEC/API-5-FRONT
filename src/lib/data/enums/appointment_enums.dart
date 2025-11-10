// lib/data/enums/appointment_enums.dart

/// Enum de status para agendamentos.
/// Mantém consistência com a documentação da API:
/// AGENDADO | REALIZADO | CANCELADO
enum AppointmentStatus { agendado, realizado, cancelado }

AppointmentStatus appointmentStatusFromString(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'REALIZADO':
      return AppointmentStatus.realizado;
    case 'CANCELADO':
      return AppointmentStatus.cancelado;
    case 'AGENDADO':
    default:
      return AppointmentStatus.agendado;
  }
}

String appointmentStatusToString(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.realizado:
      return 'REALIZADO';
    case AppointmentStatus.cancelado:
      return 'CANCELADO';
    case AppointmentStatus.agendado:
      return 'AGENDADO';
  }
}