import 'package:flutter/material.dart';
import 'package:api2025/core/constants/app_colors.dart';
import 'package:api2025/data/enums/appointment_enums.dart';

class AppointmentUIHelpers {
  static String statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.realizado:
        return 'Confirmado';
      case AppointmentStatus.cancelado:
        return 'Cancelado';
      case AppointmentStatus.agendado:
        return 'Pendente';
    }
  }

  static Color statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.realizado:
        return AppColors.greenPrimary;
      case AppointmentStatus.cancelado:
        return AppColors.red;
      case AppointmentStatus.agendado:
        return AppColors.orange;
    }
  }
}

