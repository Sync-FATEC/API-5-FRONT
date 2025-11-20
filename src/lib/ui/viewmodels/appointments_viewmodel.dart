// lib/ui/viewmodels/appointments_viewmodel.dart

import 'package:flutter/material.dart';
import '../../core/services/appointment_service.dart';
import '../../core/services/exam_service.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/enums/appointment_enums.dart';

/// ViewModel para gerenciamento de Agendamentos
/// - Controla estados de carregamento e erro
/// - Regras de negócio básicas (horário da clínica, conflitos)
class AppointmentsViewModel extends ChangeNotifier {
  final AppointmentService _service;
  final ExamService _examService;

  AppointmentsViewModel({AppointmentService? service, ExamService? examService})
    : _service = service ?? AppointmentService(),
      _examService = examService ?? ExamService();

  // Estado
  List<AppointmentModel> _items = [];
  List<ExamTypeModel> _examTypes = [];
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _error;

  // Filtros
  DateTime? _filterStart;
  DateTime? _filterEnd;
  String? _filterPatientId;
  String? _filterExamTypeId;
  AppointmentStatus? _filterStatus;

  // Getters
  List<AppointmentModel> get items => _items;
  List<ExamTypeModel> get examTypes => _examTypes;
  List<Map<String, dynamic>> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DateTime? get filterStart => _filterStart;
  DateTime? get filterEnd => _filterEnd;
  String? get filterPatientId => _filterPatientId;
  String? get filterExamTypeId => _filterExamTypeId;
  AppointmentStatus? get filterStatus => _filterStatus;

  // Helpers de exibição
  String examTypeNameById(String id) {
    final idx = _examTypes.indexWhere((e) => e.id == id);
    return idx >= 0 ? _examTypes[idx].name : id;
  }

  String patientNameById(String id) {
    final idx = _patients.indexWhere((p) => (p['id'] ?? '').toString() == id);
    if (idx >= 0) {
      final p = _patients[idx];
      final name = (p['name'] ?? p['nome'])?.toString();
      if (name != null && name.isNotEmpty) return name;
    }
    return id;
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _examTypes = await _examService.fetchExamTypes(isActive: true);
      // Ordena alfabeticamente por nome
      _examTypes.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadPatients({String query = ''}) async {
    try {
      final list = await _service.searchPatients(query);
      // Ordena alfabeticamente por nome completo
      list.sort(
        (a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo(
          (b['name'] ?? '').toString().toLowerCase(),
        ),
      );
      _patients = list;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> load({
    DateTime? start,
    DateTime? end,
    String? patientId,
    String? examTypeId,
    AppointmentStatus? status,
  }) async {
    _setLoading(true);
    try {
      _items = await _service.fetchAppointments(
        start: start,
        end: end,
        patientId: patientId,
        examTypeId: examTypeId,
        status: status,
      );
      _filterStart = start;
      _filterEnd = end;
      _filterPatientId = patientId;
      _filterExamTypeId = examTypeId;
      _filterStatus = status;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> create(AppointmentModel model) async {
    final validation = _validateAppointment(model);
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final created = await _service.createAppointment(model);
      _items = [created, ..._items];
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> fields) async {
    _setLoading(true);
    try {
      final updated = await _service.updateAppointment(id, fields);
      _items = _items.map((e) => e.id == id ? updated : e).toList();
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancel(String id) async {
    _setLoading(true);
    try {
      await _service.cancelAppointment(id);
      _items = _items.map((e) {
        if (e.id == id) {
          return AppointmentModel(
            id: e.id,
            patientId: e.patientId,
            examTypeId: e.examTypeId,
            dateTime: e.dateTime,
            status: AppointmentStatus.cancelado,
            notes: e.notes,
          );
        }
        return e;
      }).toList();
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<String?> downloadReceipt(String appointmentId, String filePath) async {
    try {
      await _service.downloadReceiptPdf(appointmentId, filePath);
      return null; // null indica sucesso
    } catch (e) {
      return e.toString();
    }
  }

  String? _validateAppointment(AppointmentModel model) {
    if (!model.isValidIds) {
      return 'Selecione paciente e tipo de exame';
    }
    // Sem restrição de horário - aceita qualquer dia e horário
    if (!model.isFutureDate) {
      return 'Data/hora deve ser futura';
    }

    // Regras de conflito: por tipo de exame e por paciente
    final examType = _examTypes.firstWhere(
      (t) => t.id == model.examTypeId,
      orElse: () =>
          const ExamTypeModel(name: '', estimatedDuration: 0, isActive: true),
    );
    final windowMinutes = examType.estimatedDuration > 0
        ? examType.estimatedDuration
        : 30;
    final windowStart = model.dateTime.subtract(
      Duration(minutes: windowMinutes),
    );
    final windowEnd = model.dateTime.add(Duration(minutes: windowMinutes));

    final conflictByType = _items.any(
      (a) =>
          a.examTypeId == model.examTypeId &&
          a.status != AppointmentStatus.cancelado &&
          (a.dateTime.isAfter(windowStart) && a.dateTime.isBefore(windowEnd)),
    );

    if (conflictByType) {
      return 'Conflito: existe agendamento do mesmo tipo no período';
    }

    final conflictByPatient = _items.any(
      (a) =>
          a.patientId == model.patientId &&
          a.status != AppointmentStatus.cancelado &&
          (a.dateTime.isAfter(windowStart) && a.dateTime.isBefore(windowEnd)),
    );
    if (conflictByPatient) {
      return 'Conflito: paciente possui agendamento no mesmo período';
    }

    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
