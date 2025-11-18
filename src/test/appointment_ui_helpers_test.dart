import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/ui/views/appointments/widgets/appointment_ui_helpers.dart';
import 'package:api2025/data/enums/appointment_enums.dart';
import 'package:api2025/core/constants/app_colors.dart';

void main() {
  test('statusLabel maps enum to display labels', () {
    expect(
      AppointmentUIHelpers.statusLabel(AppointmentStatus.agendado),
      'Agendado',
    );
    expect(
      AppointmentUIHelpers.statusLabel(AppointmentStatus.realizado),
      'Realizado',
    );
    expect(
      AppointmentUIHelpers.statusLabel(AppointmentStatus.cancelado),
      'Cancelado',
    );
  });

  test('statusColor maps enum to design tokens', () {
    expect(
      AppointmentUIHelpers.statusColor(AppointmentStatus.agendado),
      AppColors.orange,
    );
    expect(
      AppointmentUIHelpers.statusColor(AppointmentStatus.realizado),
      AppColors.greenPrimary,
    );
    expect(
      AppointmentUIHelpers.statusColor(AppointmentStatus.cancelado),
      AppColors.red,
    );
  });
}
