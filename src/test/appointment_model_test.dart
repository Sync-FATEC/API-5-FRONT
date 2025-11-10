import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/data/models/appointment_model.dart';
import 'package:api2025/data/enums/appointment_enums.dart';

void main() {
  group('AppointmentModel', () {
    test('serializa e desserializa corretamente', () {
      final now = DateTime.now().toUtc();
      final model = AppointmentModel(
        id: 'a1',
        patientId: 'p1',
        examTypeId: 'e1',
        dateTime: now,
        status: AppointmentStatus.agendado,
        notes: 'Observação',
      );

      final json = model.toJson();
      expect(json['pacienteId'], 'p1');
      expect(json['examTypeId'], 'e1');
      expect(json['dataHora'], now.toIso8601String());
      expect(json['status'], 'AGENDADO');

      final parsed = AppointmentModel.fromJson(json);
      expect(parsed.id, 'a1');
      expect(parsed.patientId, 'p1');
      expect(parsed.examTypeId, 'e1');
      expect(parsed.status, AppointmentStatus.agendado);
      expect(parsed.notes, 'Observação');
    });

    test('validações básicas', () {
      final past = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final m1 = AppointmentModel(patientId: 'p1', examTypeId: 'e1', dateTime: past);
      expect(m1.isFutureDate, false);

      final m2 = AppointmentModel(patientId: '', examTypeId: 'e1', dateTime: DateTime.now().toUtc());
      expect(m2.isValidIds, false);
    });
  });
}