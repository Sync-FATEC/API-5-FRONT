import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/ui/viewmodels/appointments_viewmodel.dart';
import 'package:api2025/core/services/appointment_service.dart';
import 'package:api2025/core/services/exam_service.dart';
import 'package:api2025/data/models/appointment_model.dart';
import 'package:api2025/data/models/exam_type_model.dart';
import 'package:api2025/data/enums/appointment_enums.dart';

class _FakeAppointmentService extends AppointmentService {
  @override
  Future<AppointmentModel> createAppointment(AppointmentModel model) async {
    // retorna o mesmo para simular sucesso sem rede
    return model;
  }

  @override
  Future<List<AppointmentModel>> fetchAppointments({DateTime? start, DateTime? end, String? patientId, String? examTypeId, AppointmentStatus? status}) async {
    return [];
  }
}

class _FakeExamService extends ExamService {
  @override
  Future<List<ExamTypeModel>> fetchExamTypes({String? query, bool? isActive}) async {
    return [
      const ExamTypeModel(id: 'e1', name: 'US Abdômen', description: null, estimatedDuration: 30, isActive: true),
    ];
  }
}

void main() {
  group('AppointmentsViewModel', () {
    test('bloqueia horários fora da clínica e datas passadas', () async {
      final vm = AppointmentsViewModel(service: _FakeAppointmentService(), examService: _FakeExamService());
      await vm.initialize();

      // Sábado 07:00
      final dtWeekend = DateTime.now().toLocal();
      final saturday = dtWeekend.add(Duration(days: (6 - dtWeekend.weekday))); // próximo sábado
      final saturdaySeven = DateTime(saturday.year, saturday.month, saturday.day, 7, 0).toUtc();

      final invalid = AppointmentModel(patientId: 'p1', examTypeId: 'e1', dateTime: saturdaySeven);
      final ok = await vm.create(invalid);
      expect(ok, false);
      expect(vm.error, isNotNull);
    });

    test('detecta conflitos por paciente e tipo', () async {
      final vm = AppointmentsViewModel(service: _FakeAppointmentService(), examService: _FakeExamService());
      await vm.initialize();

      // Cria um agendamento base
      final baseDate = DateTime.now().toLocal().add(const Duration(days: 2));
      final baseLocal = DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0).toUtc();
      final a1 = AppointmentModel(patientId: 'p1', examTypeId: 'e1', dateTime: baseLocal);
      await vm.create(a1);

      // Novo agendamento com conflito de paciente
      final a2 = AppointmentModel(patientId: 'p1', examTypeId: 'e1', dateTime: baseLocal.add(const Duration(minutes: 15)));
      final ok2 = await vm.create(a2);
      expect(ok2, false);
      expect(vm.error, isNotNull);
    });
  });
}