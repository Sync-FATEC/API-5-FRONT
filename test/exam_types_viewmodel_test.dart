import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/ui/viewmodels/exam_types_viewmodel.dart';
import 'package:api2025/core/services/exam_service.dart';
import 'package:api2025/data/models/exam_type_model.dart';

class _FakeExamService extends ExamService {
  final List<ExamTypeModel> _db = [];

  @override
  Future<List<ExamTypeModel>> fetchExamTypes({String? query, bool? isActive}) async {
    return _db;
  }

  @override
  Future<ExamTypeModel> createExamType(ExamTypeModel model) async {
    final created = ExamTypeModel(
      id: (model.id ?? DateTime.now().millisecondsSinceEpoch.toString()),
      name: model.name,
      description: model.description,
      estimatedDuration: model.estimatedDuration,
      requiredPreparation: model.requiredPreparation,
      isActive: model.isActive,
    );
    _db.add(created);
    return created;
  }

  @override
  Future<ExamTypeModel> updateExamType(String id, Map<String, dynamic> fields) async {
    final idx = _db.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Not found');
    final current = _db[idx];
    final updated = ExamTypeModel(
      id: current.id,
      name: (fields['nome'] ?? current.name) as String,
      description: (fields['descricao'] ?? current.description) as String?,
      estimatedDuration: (fields['duracaoEstimada'] ?? current.estimatedDuration) as int,
      requiredPreparation: (fields['preparoNecessario'] ?? current.requiredPreparation) as String?,
      isActive: current.isActive,
    );
    _db[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteExamType(String id) async {
    _db.removeWhere((e) => e.id == id);
  }
}

void main() {
  group('ExamTypesViewModel', () {
    test('create success adds item', () async {
      final fake = _FakeExamService();
      final vm = ExamTypesViewModel(service: fake);
      final ok = await vm.create(ExamTypeModel(name: 'Raio-X', estimatedDuration: 30));
      expect(ok, isTrue);
      expect(vm.items.length, 1);
      expect(vm.error, isNull);
    });

    test('create invalid duration fails with error', () async {
      final fake = _FakeExamService();
      final vm = ExamTypesViewModel(service: fake);
      final ok = await vm.create(ExamTypeModel(name: 'USG', estimatedDuration: 0));
      expect(ok, isFalse);
      expect(vm.error, isNotNull);
    });

    test('update success modifies existing item', () async {
      final fake = _FakeExamService();
      final vm = ExamTypesViewModel(service: fake);
      final created = await vm.create(ExamTypeModel(name: 'Tomografia', estimatedDuration: 45));
      expect(created, isTrue);
      final id = vm.items.first.id!;
      final ok = await vm.update(id, {'nome': 'Tomografia Computadorizada', 'duracaoEstimada': 50});
      expect(ok, isTrue);
      expect(vm.items.first.name, 'Tomografia Computadorizada');
      expect(vm.items.first.estimatedDuration, 50);
    });

    test('update with empty id fails', () async {
      final fake = _FakeExamService();
      final vm = ExamTypesViewModel(service: fake);
      final ok = await vm.update('', {'nome': 'ABC'});
      expect(ok, isFalse);
      expect(vm.error, isNotNull);
    });
  });
}